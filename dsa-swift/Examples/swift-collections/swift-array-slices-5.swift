// Generated from src/dsa/content/lessons/swift-collections/swift-array-slices.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [10, 20, 30, 40, 50, 60]
let middle = numbers[2...4]

print(middle.first ?? -1)
print(middle[middle.startIndex])
for i in middle.indices {
    print(i, middle[i])
}

let fresh = Array(middle)
print(fresh[0], fresh.indices)
