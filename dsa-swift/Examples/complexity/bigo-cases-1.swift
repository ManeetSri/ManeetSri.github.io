// Generated from src/dsa/content/lessons/complexity/bigo-cases.mdx. Edit the lesson, then run
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

let numbers = Array(1...10)
var counts: [Int] = []
for target in numbers {
    counts.append(comparisons(toFind: target, in: numbers))
}
print(counts)
print("best:", counts.min()!, "worst:", counts.max()!)
print("average:", Double(counts.reduce(0, +)) / Double(counts.count))
print("missing target:", comparisons(toFind: 99, in: numbers))
