// Generated from src/dsa/content/lessons/divide-conquer/dc-paradigm.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The largest value, by divide and conquer. Each call prints its range, indented by depth.
func largest(_ numbers: [Int], _ low: Int, _ high: Int, depth: Int = 0) -> Int {
    let indent = String(repeating: "    ", count: depth)
    if high - low == 1 {                                   // base case: one element
        print("\(indent)\([numbers[low]]) → \(numbers[low])")
        return numbers[low]
    }
    print("\(indent)\(Array(numbers[low..<high]))")
    let mid = low + (high - low) / 2                       // divide
    let left = largest(numbers, low, mid, depth: depth + 1)    // conquer
    let right = largest(numbers, mid, high, depth: depth + 1)
    let answer = max(left, right)                          // combine
    print("\(indent)max(\(left), \(right)) = \(answer)")
    return answer
}

let numbers = [3, 9, 4, 1, 7, 2]
print("answer:", largest(numbers, 0, numbers.count))
