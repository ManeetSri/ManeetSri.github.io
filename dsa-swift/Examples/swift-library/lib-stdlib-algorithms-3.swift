// Generated from src/dsa/content/lessons/swift-library/lib-stdlib-algorithms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let fruit = ["apple", "avocado", "banana", "blueberry", "cherry"]
let byLetter = Dictionary(grouping: fruit) { $0.first! }
for letter in byLetter.keys.sorted() {
    print(letter, byLetter[letter]!)
}

let lengthCounts = fruit.reduce(into: [Int: Int]()) { counts, word in
    counts[word.count, default: 0] += 1
}
print(lengthCounts.keys.sorted().map { "\($0) letters: \(lengthCounts[$0]!)" })

let names = ["Ada", "Ben", "Cy"]
let ages = [36, 29, 41, 50]
for (name, age) in zip(names, ages) {
    print(name, age)
}

print(Array(stride(from: 10, to: 0, by: -3)))
print(Array(stride(from: 0.0, through: 1.0, by: 0.25)))

let row = "id,,name,score"
print(row.split(separator: ","))
print(row.split(separator: ",", omittingEmptySubsequences: false))
print(["a", "b", "c"].joined(separator: "-"))
print(Array([[1, 2], [3], [4, 5]].joined()))

let grid = Array(repeating: Array(repeating: 0, count: 3), count: 2)
print(grid)
