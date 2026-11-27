// Generated from src/dsa/content/lessons/arrays/arrays-leaders-majority.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func majorityCandidate(_ numbers: [Int]) -> Int? {
    var candidate: Int? = nil
    var votes = 0
    for number in numbers {
        if votes == 0 {
            candidate = number
            votes = 1
        } else if number == candidate {
            votes += 1
        } else {
            votes -= 1
        }
    }
    return candidate
}

for numbers in [[2, 2, 1, 1, 1, 2, 2], [3, 1, 3], [1, 2, 3], [4, 4, 1, 1]] {
    if let candidate = majorityCandidate(numbers) {
        let count = numbers.filter { $0 == candidate }.count
        let verdict = count > numbers.count / 2 ? "majority" : "not a majority"
        print(numbers, "candidate", candidate, "appears", count, "times:", verdict)
    }
}
