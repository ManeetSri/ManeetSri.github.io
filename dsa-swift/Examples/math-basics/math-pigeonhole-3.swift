// Generated from src/dsa/content/lessons/math-basics/math-pigeonhole.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func blockDivisibleByCount(_ numbers: [Int]) -> (start: Int, end: Int) {
    let n = numbers.count
    var firstSeen = Array(repeating: -1, count: n)
    firstSeen[0] = 0
    var total = 0
    for (i, value) in numbers.enumerated() {
        total = (total + value) % n
        if firstSeen[total] != -1 {
            return (firstSeen[total], i)
        }
        firstSeen[total] = i + 1
    }
    return (-1, -1)
}

let numbers = [3, 4, 1, 7, 2]
let block = blockDivisibleByCount(numbers)
print(block.start, block.end, numbers[block.start...block.end])
