// Generated from src/dsa/content/lessons/complexity/bigo-counting-operations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func comparisons(toFind target: Int, in numbers: [Int]) -> Int {
    var count = 0
    for number in numbers {
        count += 1
        if number == target {
            return count
        }
    }
    return count
}

let numbers = Array(1...100)
print(comparisons(toFind: 1, in: numbers))
print(comparisons(toFind: 50, in: numbers))
print(comparisons(toFind: 999, in: numbers))
