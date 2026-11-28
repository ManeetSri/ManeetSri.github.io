// Generated from src/dsa/content/lessons/prefix-sums/prefix-product-except-self.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [2, 3, 4, 5]
let n = numbers.count

var left = Array(repeating: 1, count: n)
for i in 1..<n {
    left[i] = left[i - 1] * numbers[i - 1]
}

var right = Array(repeating: 1, count: n)
for i in stride(from: n - 2, through: 0, by: -1) {
    right[i] = right[i + 1] * numbers[i + 1]
}

var answer: [Int] = []
for i in 0..<n {
    answer.append(left[i] * right[i])
}
print("left:  ", left)
print("right: ", right)
print("answer:", answer)
