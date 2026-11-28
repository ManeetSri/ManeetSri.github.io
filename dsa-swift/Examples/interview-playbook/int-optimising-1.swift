// Generated from src/dsa/content/lessons/interview-playbook/int-optimising.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countSlow(_ numbers: [Int], _ k: Int) -> Int {
    var count = 0
    for start in numbers.indices {
        var sum = 0
        for end in start..<numbers.count {
            sum += numbers[end]
            if sum == k { count += 1 }
        }
    }
    return count
}

func countFast(_ numbers: [Int], _ k: Int) -> Int {
    var seen: [Int: Int] = [0: 1]      // prefix sum -> how many times it has occurred
    var prefix = 0
    var count = 0
    for number in numbers {
        prefix += number
        count += seen[prefix - k, default: 0]
        seen[prefix, default: 0] += 1
    }
    return count
}

let numbers = [3, 4, -7, 1, 3, 3, 1, -4]
print(countSlow(numbers, 7), countFast(numbers, 7))
