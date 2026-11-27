// Generated from src/dsa/content/lessons/swift-collections/swift-sets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let backend: Set = ["Ada", "Grace", "Linus"]
let frontend: Set = ["Grace", "Tim", "Linus", "Margaret"]

print(backend.union(frontend).sorted())
print(backend.intersection(frontend).sorted())
print(backend.subtracting(frontend).sorted())
print(backend.symmetricDifference(frontend).sorted())
