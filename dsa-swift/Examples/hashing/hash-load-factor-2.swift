// Generated from src/dsa/content/lessons/hashing/hash-load-factor.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

for key in [5, 13, 21, 29] {
    print("key \(key): bucket \(key % 8) of 8, bucket \(key % 16) of 16")
}
