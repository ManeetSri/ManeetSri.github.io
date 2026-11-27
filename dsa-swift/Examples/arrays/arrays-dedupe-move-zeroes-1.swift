// Generated from src/dsa/content/lessons/arrays/arrays-dedupe-move-zeroes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func removeAll(_ target: Int, from numbers: inout [Int]) -> Int {
    var write = 0
    for read in 0..<numbers.count where numbers[read] != target {
        numbers[write] = numbers[read]
        write += 1
    }
    return write
}

var values = [3, 1, 3, 3, 2, 3, 4]
let kept = removeAll(3, from: &values)
print(kept, Array(values[..<kept]))
print(values)
