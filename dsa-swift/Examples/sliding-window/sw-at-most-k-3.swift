// Generated from src/dsa/content/lessons/sliding-window/sw-at-most-k.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sumAtMost(_ bits: [Int], _ limit: Int) -> Int {
    guard limit >= 0 else { return 0 }
    var left = 0
    var sum = 0
    var total = 0
    for right in 0..<bits.count {
        sum += bits[right]
        while sum > limit {
            sum -= bits[left]
            left += 1
        }
        total += right - left + 1
    }
    return total
}

func sumExactly(_ bits: [Int], _ target: Int) -> Int {
    sumAtMost(bits, target) - sumAtMost(bits, target - 1)
}

print(sumExactly([1, 0, 1, 0, 1], 2))
print(sumExactly([0, 0, 0], 0))

// Exactly k odd numbers: turn each number into 1 if odd, 0 if even
let numbers = [3, 8, 5, 6, 7, 2]
print(sumExactly(numbers.map { $0 % 2 == 0 ? 0 : 1 }, 2))
