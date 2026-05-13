import p5 from "p5";
import { ParticleSystem } from "./particleSystem";
import type { TuioInput } from "./tuioInput";

export interface SerialVisualState {
  b1in: number;
  b2in: number;
  poti: number;
}

const TABLE_SIZE = 760;

function pickTriangle(
  s: SerialVisualState,
): "white" | "red" | "green" | "yellow" {
  if (s.b1in === 1 && s.b2in === 1) return "yellow";
  if (s.b2in === 1) return "red";
  if (s.b1in === 1) return "green";
  return "white";
}

function tuioToScreen(p: p5, obj: { x: number; y: number }): p5.Vector {
  const sx = obj.x * p.width;
  const sy = (1 - obj.y) * p.height;
  return p.createVector(sx, sy);
}

function syncOriginFromTuio(
  ps: ParticleSystem,
  p: p5,
  obj: { x: number; y: number },
): void {
  const pos = tuioToScreen(p, obj);
  ps.particleSystemPos.set(pos.x, pos.y);
  ps.origin.set(pos.x, pos.y);
}

export function mountSketch(
  parent: HTMLElement,
  tuioInput: TuioInput,
  getSerial: () => SerialVisualState,
): p5 {
  let ps: ParticleSystem;
  const images: Record<"white" | "red" | "green" | "yellow", p5.Image | null> = {
    white: null,
    red: null,
    green: null,
    yellow: null,
  };

  return new p5((p) => {
    p.preload = () => {
      const base = import.meta.env.BASE_URL;
      images.white = p.loadImage(`${base}triangle_white.png`);
      images.red = p.loadImage(`${base}triangle_red.png`);
      images.green = p.loadImage(`${base}triangle_green.png`);
      images.yellow = p.loadImage(`${base}triangle_yellow.png`);
    };

    p.setup = () => {
      const w = Math.min(1200, Math.max(400, window.innerWidth - 24));
      const h = Math.min(800, Math.max(320, window.innerHeight - 220));
      p.createCanvas(w, h);
      ps = new ParticleSystem(p.createVector(0, 0));
    };

    p.windowResized = () => {
      const w = Math.min(1200, Math.max(400, window.innerWidth - 24));
      const h = Math.min(800, Math.max(320, window.innerHeight - 220));
      p.resizeCanvas(w, h);
    };

    p.draw = () => {
      const serial = getSerial();
      const curKey = pickTriangle(serial);
      const curTriangle = images[curKey] ?? images.white;
      if (!curTriangle) return;

      p.background(0);
      ps.addParticle(p);

      const scaleFactor = p.height / TABLE_SIZE;
      p.textSize(18 * scaleFactor);
      p.fill(255);
      p.noStroke();

      const objects = tuioInput.getObjects(p);
      for (const obj of objects) {
        syncOriginFromTuio(ps, p, obj);
        p.push();
        const pos = tuioToScreen(p, obj);
        p.translate(pos.x, pos.y);
        p.rotate(obj.angleRad);
        const sym = obj.symbolId;
        if (sym === 0 || sym === 1 || sym === 2) {
          ps.run(p, sym, serial.poti, curTriangle);
        }
        p.pop();
      }
    };
  }, parent);
}
