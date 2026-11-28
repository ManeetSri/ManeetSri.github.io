// Generated from src/dsa/content/lessons/arrays/arrays-insert-delete-cost.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Inserts value at index by shifting by hand, and returns how many elements moved
func insert(_ value: Int, at index: Int, into numbers: inout [Int]) -> Int {
    numbers.append(0)                         // one extra slot at the end
    var moved = 0
    var position = numbers.count - 1
    while position > index {
        numbers[position] = numbers[position - 1]
        position -= 1
        moved += 1
    }
    numbers[index] = value
    return moved
}

let n = 1_000
var atFront: [Int] = []
var inMiddle: [Int] = []
var atEnd: [Int] = []
var frontMoves = 0
var middleMoves = 0
var endMoves = 0
for value in 0..<n {
    frontMoves += insert(value, at: 0, into: &atFront)
    middleMoves += insert(value, at: inMiddle.count / 2, into: &inMiddle)
    endMoves += insert(value, at: atEnd.count, into: &atEnd)
}
print("front: \(frontMoves) moves")
print("middle: \(middleMoves) moves")
print("end: \(endMoves) moves")
