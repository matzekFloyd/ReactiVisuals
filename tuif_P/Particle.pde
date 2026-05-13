// Simple particle used by ParticleSystem; reads sketch globals poti and curTriangle for id 2.

class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;

  Particle(PVector l) {
    acceleration = new PVector(0, 0.075);
    velocity = new PVector(random(-1, 1), random(-2, 0));
    position = l.copy();
    lifespan = 150.0;
  }

  void run(int id, int number) {
    update();
    display(id, number);
  }

  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 1.0;
  }

  void display(int id, int number) {
    if (id == 0) {
      float d = map(poti, 0, 2, 10, 70);
      ellipse(position.x, position.y, d, d);
    } else if (id == 1) {
      textSize(map(poti, 0, 2, 20, 60));
      text(number == 1 ? "1" : "0", position.x, position.y);
    } else if (id == 2) {
      float s = map(poti, 0, 2, 10, 70);
      image(curTriangle, position.x, position.y, s, s);
    }
  }

  boolean isDead() {
    return lifespan < 0.0;
  }
}
