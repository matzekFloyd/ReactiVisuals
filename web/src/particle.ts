import type p5 from "p5";

export class Particle {
  position: p5.Vector;
  velocity: p5.Vector;
  acceleration: p5.Vector;
  lifespan: number;

  constructor(p: p5, origin: p5.Vector) {
    this.acceleration = p.createVector(0, 0.075);
    this.velocity = p.createVector(p.random(-1, 1), p.random(-2, 0));
    this.position = origin.copy();
    this.lifespan = 150;
  }

  run(p: p5, id: number, bit: number, poti: number, triangle: p5.Image): void {
    this.update(p);
    this.display(p, id, bit, poti, triangle);
  }

  private update(_p: p5): void {
    this.velocity.add(this.acceleration);
    this.position.add(this.velocity);
    this.lifespan -= 1;
  }

  private display(p: p5, id: number, bit: number, poti: number, triangle: p5.Image): void {
    if (id === 0) {
      const d = p.map(poti, 0, 2, 10, 70);
      p.circle(this.position.x, this.position.y, d);
    } else if (id === 1) {
      p.textSize(p.map(poti, 0, 2, 20, 60));
      p.text(bit === 1 ? "1" : "0", this.position.x, this.position.y);
    } else if (id === 2) {
      const s = p.map(poti, 0, 2, 10, 70);
      p.image(triangle, this.position.x, this.position.y, s, s);
    }
  }

  isDead(): boolean {
    return this.lifespan < 0;
  }
}
