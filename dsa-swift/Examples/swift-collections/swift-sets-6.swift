// Generated from src/dsa/content/lessons/swift-collections/swift-sets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let small: Set = [1, 2]
let big: Set = [1, 2, 3]
print(small.isSubset(of: big))
print(big.isSuperset(of: small))
print(small.isDisjoint(with: [7, 8]))
print(Set([1, 2, 3]) == Set([3, 2, 1]))
