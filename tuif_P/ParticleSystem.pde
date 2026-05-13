// Manages particles; origin follows the active TUIO object via changeParticleSystemPosition().

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;
  PVector particleSystemPos;

  ParticleSystem(PVector position) {
    particleSystemPos = position.copy();
    origin = position.copy();
    particles = new ArrayList<Particle>();
  }

  void addParticle() {
    particles.add(new Particle(origin));
  }

  int generateNumber() {
    return random(-1, 1) >= 0 ? 1 : 0;
  }

  void run(int id) {
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run(id, generateNumber());
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}
