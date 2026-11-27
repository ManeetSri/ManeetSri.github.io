// Generated from src/dsa/content/lessons/arrays/arrays-reverse-rotate.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func rotate(_ numbers: inout [Int], by k: Int) {
    let n = numbers.count
    guard n > 1 else { return }
    let steps = ((k % n) + n) % n        // in 0..<n, whatever the sign of k
    guard steps > 0 else { return }
    numbers.reverse()
    numbers[..<steps].reverse()
    numbers[steps...].reverse()
}

var values = [1, 2, 3, 4, 5, 6, 7]
rotate(&values, by: 3)
print(values)
rotate(&values, by: -3)
print(values)
rotate(&values, by: 1_000_000_004)
print(values)

var empty: [Int] = []
rotate(&empty, by: 4)
print(empty)
