// Generated from src/dsa/content/lessons/arrays/arrays-dedupe-move-zeroes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func moveZeroesByFilling(_ numbers: inout [Int]) {
    var write = 0
    for read in 0..<numbers.count where numbers[read] != 0 {
        numbers[write] = numbers[read]
        write += 1
    }
    for index in write..<numbers.count {
        numbers[index] = 0
    }
}

func moveZeroesBySwapping(_ numbers: inout [Int]) {
    var write = 0
    for read in 0..<numbers.count where numbers[read] != 0 {
        numbers.swapAt(read, write)
        write += 1
    }
}

var first = [0, 1, 0, 3, 12]
var second = first
moveZeroesByFilling(&first)
moveZeroesBySwapping(&second)
print(first)
print(second)
