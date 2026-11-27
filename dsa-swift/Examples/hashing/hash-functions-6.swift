// Generated from src/dsa/content/lessons/hashing/hash-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var first = Hasher()
first.combine("swift")
first.combine(42)

var second = Hasher()
second.combine("swift")
second.combine(42)

print(first.finalize() == second.finalize())
print("swift".hashValue == "swift".hashValue)
