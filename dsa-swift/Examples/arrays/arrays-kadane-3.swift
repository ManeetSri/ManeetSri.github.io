// Generated from src/dsa/content/lessons/arrays/arrays-kadane.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func kadaneFromZero(_ numbers: [Int]) -> Int {
    var current = 0
    var best = 0
    for value in numbers {
        current = max(0, current + value)
        best = max(best, current)
    }
    return best
}

func kadane(_ numbers: [Int]) -> Int {
    var current = numbers[0]
    var best = numbers[0]
    for value in numbers.dropFirst() {
        current = max(value, current + value)
        best = max(best, current)
    }
    return best
}

let losses = [-3, -1, -2]
print(kadaneFromZero(losses), kadane(losses))
print(kadaneFromZero([5, -9, 6]), kadane([5, -9, 6]))
