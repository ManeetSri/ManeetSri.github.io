// Generated from src/dsa/content/lessons/problem-solving/algo-what-is-an-algorithm.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sumByLoop(upTo n: Int) -> Int {
    var total = 0
    for number in 1...n {
        total += number
    }
    return total
}

func sumByFormula(upTo n: Int) -> Int {
    n * (n + 1) / 2
}

print(sumByLoop(upTo: 100))
print(sumByFormula(upTo: 100))
