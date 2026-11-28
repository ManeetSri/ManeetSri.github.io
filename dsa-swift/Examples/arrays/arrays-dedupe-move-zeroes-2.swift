// Generated from src/dsa/content/lessons/arrays/arrays-dedupe-move-zeroes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func removeDuplicates(_ numbers: inout [Int]) -> Int {
    guard !numbers.isEmpty else { return 0 }
    var write = 1
    for read in 1..<numbers.count where numbers[read] != numbers[write - 1] {
        numbers[write] = numbers[read]
        write += 1
    }
    return write
}

var sorted = [1, 1, 2, 2, 2, 3, 5, 5]
let unique = removeDuplicates(&sorted)
sorted.removeLast(sorted.count - unique)
print(unique, sorted)

var single = [7]
print(removeDuplicates(&single))
var nothing: [Int] = []
print(removeDuplicates(&nothing))
