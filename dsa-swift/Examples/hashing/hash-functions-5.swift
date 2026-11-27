// Generated from src/dsa/content/lessons/hashing/hash-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var buckets = Array(repeating: 0, count: 8)
for key in stride(from: 0, to: 64, by: 8) {     // 0, 8, 16, ..., 56
    buckets[key & 7] += 1
}
print(buckets)
