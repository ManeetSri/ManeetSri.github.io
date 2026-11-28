// Generated from src/dsa/content/lessons/divide-conquer/dc-max-subarray.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var additions = 0

func crossingSum(_ numbers: [Int], _ low: Int, _ mid: Int, _ high: Int) -> Int {
    var sum = 0
    var bestLeft = numbers[mid - 1]
    for index in stride(from: mid - 1, through: low, by: -1) {
        sum += numbers[index]
        bestLeft = max(bestLeft, sum)
    }
    sum = 0
    var bestRight = numbers[mid]
    for index in mid..<high {
        sum += numbers[index]
        bestRight = max(bestRight, sum)
    }
    additions += high - low
    return bestLeft + bestRight
}

func bestSum(_ numbers: [Int], _ low: Int, _ high: Int) -> Int {
    if high - low == 1 {
        return numbers[low]
    }
    let mid = low + (high - low) / 2
    return max(bestSum(numbers, low, mid), bestSum(numbers, mid, high), crossingSum(numbers, low, mid, high))
}

func kadane(_ numbers: [Int]) -> Int {
    var current = numbers[0]
    var best = numbers[0]
    for value in numbers.dropFirst() {
        additions += 1
        current = max(value, current + value)
        best = max(best, current)
    }
    return best
}

// A small seeded generator, so the "random" arrays are the same on every run
var seed: UInt64 = 2_024
func nextRandom(_ range: ClosedRange<Int>) -> Int {
    seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
    return range.lowerBound + Int((seed >> 33) % UInt64(range.count))
}

var agree = 0
for _ in 0..<1_000 {
    let numbers = (0..<nextRandom(1...30)).map { _ in nextRandom(-20...20) }
    if bestSum(numbers, 0, numbers.count) == kadane(numbers) {
        agree += 1
    }
}
print("agree on \(agree) of 1000 random arrays")

for n in [1_000, 100_000] {
    let numbers = (0..<n).map { _ in nextRandom(-100...100) }
    additions = 0
    let split = bestSum(numbers, 0, n)
    let splitWork = additions
    additions = 0
    let scan = kadane(numbers)
    print("n = \(n): both find \(split == scan ? "the same sum" : "different sums"); divide and conquer \(splitWork) additions, Kadane \(additions)")
}
