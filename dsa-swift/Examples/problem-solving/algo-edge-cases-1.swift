// Generated from src/dsa/content/lessons/problem-solving/algo-edge-cases.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func spread(_ numbers: [Int]) -> Int? {
    guard let smallest = numbers.min(), let largest = numbers.max() else {
        return nil
    }
    return largest - smallest
}

let cases: [[Int]] = [[], [7], [4, 4], [-5, -2], [1_000_000_000, -1_000_000_000]]
for numbers in cases {
    if let answer = spread(numbers) {
        print(numbers, "has spread", answer)
    } else {
        print(numbers, "has no spread")
    }
}
