// Generated from src/dsa/content/lessons/swift-functions/swift-returning-tuples.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countParity(of numbers: [Int]) -> (evens: Int, odds: Int) {
    var evens = 0
    var odds = 0
    for number in numbers {
        if number % 2 == 0 {
            evens += 1
        } else {
            odds += 1
        }
    }
    return (evens, odds)
}

let counts = countParity(of: [3, 8, 6, 1, 4])
print("Evens: \(counts.evens), odds: \(counts.odds)")
