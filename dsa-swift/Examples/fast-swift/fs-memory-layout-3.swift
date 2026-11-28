// Generated from src/dsa/content/lessons/fast-swift/fs-memory-layout.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Particle {
    var x: Double
    init(x: Double) { self.x = x }
}

var particles = ContiguousArray<Particle>()
particles.reserveCapacity(4)
for i in 0..<4 {
    particles.append(Particle(x: Double(i)))
}
for particle in particles {
    particle.x *= 2
}

let positions = particles.map { $0.x }
print(positions)
print(type(of: positions))
print(type(of: ContiguousArray(positions)))
