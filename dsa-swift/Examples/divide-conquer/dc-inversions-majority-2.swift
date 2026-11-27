// Generated from src/dsa/content/lessons/divide-conquer/dc-inversions-majority.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Majority by divide and conquer: a majority of the whole must be a majority of one half
func occurrences(of value: Int, in numbers: [Int], _ low: Int, _ high: Int) -> Int {
    var count = 0
    for index in low..<high where numbers[index] == value {
        count += 1
    }
    return count
}

func combine(_ left: Int?, _ right: Int?, _ numbers: [Int], _ low: Int, _ high: Int) -> Int? {
    if left == right {
        return left                               // both halves agree, or neither has a majority
    }
    for candidate in [left, right] {
        if let candidate, occurrences(of: candidate, in: numbers, low, high) > (high - low) / 2 {
            return candidate
        }
    }
    return nil
}

func majority(_ numbers: [Int], _ low: Int, _ high: Int) -> Int? {
    if high - low == 1 {
        return numbers[low]                       // one element is its own majority
    }
    let mid = low + (high - low) / 2
    let left = majority(numbers, low, mid)
    let right = majority(numbers, mid, high)
    let answer = combine(left, right, numbers, low, high)
    let show = { (value: Int?) in value.map(String.init) ?? "none" }
    print("\(Array(numbers[low..<high])): left \(show(left)), right \(show(right)) → \(show(answer))")
    return answer
}

let numbers = [2, 2, 1, 1, 1, 2, 2]
_ = majority(numbers, 0, numbers.count)
