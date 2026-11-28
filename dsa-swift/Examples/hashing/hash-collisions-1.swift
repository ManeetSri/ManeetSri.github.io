// Generated from src/dsa/content/lessons/hashing/hash-collisions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func chanceOfCollision(keys: Int, buckets: Int) -> Double {
    var allDifferent = 1.0
    for k in 0..<keys {
        allDifferent *= Double(buckets - k) / Double(buckets)   // the next key avoids the k taken buckets
    }
    return 1 - allDifferent
}

for (keys, buckets) in [(23, 365), (50, 365), (40, 1_000), (120, 10_000)] {
    let percent = Int((chanceOfCollision(keys: keys, buckets: buckets) * 100).rounded())
    print("\(keys) keys in \(buckets) buckets: \(percent)% chance of a collision")
}
