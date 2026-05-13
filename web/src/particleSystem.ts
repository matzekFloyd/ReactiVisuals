import type p5 from "p5";
import { Particle } from "./particle";

export class ParticleSystem {
  particles: Particle[] = [];
  origin: p5.Vector;
  particleSystemPos: p5.Vector;

  constructor(position: p5.Vector) {
    this.particleSystemPos = position.copy();
    this.origin = position.copy();
  }

  addParticle(p: p5): void {
    this.particles.push(new Particle(p, this.origin));
  }

  private generateNumber(p: p5): number {
    return p.random(-1, 1) >= 0 ? 1 : 0;
  }

  run(p: p5, id: number, poti: number, triangle: p5.Image): void {
    for (let i = this.particles.length - 1; i >= 0; i--) {
      const part = this.particles[i]!;
      part.run(p, id, this.generateNumber(p), poti, triangle);
      if (part.isDead()) {
        this.particles.splice(i, 1);
      }
    }
  }
}
