// Generated from src/dsa/content/lessons/complexity/bigo-analysing-loops.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func runSteps(_ numbers: [Int]) -> (runs: Int, innerSteps: Int) {
    var runs = 0
    var innerSteps = 0
    var start = 0
    while start < numbers.count {
        var end = start
        while end < numbers.count && numbers[end] == numbers[start] {
            end += 1
            innerSteps += 1
        }
        runs += 1
        start = end
    }
    return (runs, innerSteps)
}

print(runSteps([7, 7, 7, 2, 2, 9, 7, 7]))
print(runSteps(Array(repeating: 5, count: 1_000)))
print(runSteps(Array(0..<1_000)))
