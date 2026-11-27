// Generated from src/dsa/content/lessons/arrays/arrays-leaders-majority.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func leadersBruteForce(_ numbers: [Int]) -> [Int] {
    var result: [Int] = []
    for i in numbers.indices {
        var isLeader = true
        for j in (i + 1)..<numbers.count where numbers[j] >= numbers[i] {
            isLeader = false
        }
        if isLeader {
            result.append(numbers[i])
        }
    }
    return result
}

func leaders(_ numbers: [Int]) -> [Int] {
    guard let last = numbers.last else { return [] }
    var result = [last]                    // the last element always leads
    var largestToTheRight = last
    for value in numbers.dropLast().reversed() where value > largestToTheRight {
        result.append(value)
        largestToTheRight = value
    }
    return result.reversed()               // found right to left
}

let numbers = [16, 17, 4, 3, 5, 2]
print(leadersBruteForce(numbers))
print(leaders(numbers))
print(leaders([5, 5, 3]))
print(leaders([]))
