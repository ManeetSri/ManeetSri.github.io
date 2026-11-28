// Generated from src/dsa/content/lessons/swift-collections/swift-dictionaries.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let names = ["ada", "grace", "linus"]
let years = [1815, 1906, 1969]
let born = Dictionary(uniqueKeysWithValues: zip(names, years))
print(born["grace"] ?? 0)
print(born.keys.sorted())
