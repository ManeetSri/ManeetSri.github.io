// Generated from src/dsa/content/lessons/prefix-sums/prefix-product-except-self.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func productsExceptSelf(_ numbers: [Int]) -> [Int] {
    let n = numbers.count
    var answer = Array(repeating: 1, count: n)

    // Pass 1: answer[i] = product of everything left of i
    var prefix = 1
    for i in 0..<n {
        answer[i] = prefix
        prefix *= numbers[i]
    }

    // Pass 2: multiply in the product of everything right of i
    var suffix = 1
    for i in stride(from: n - 1, through: 0, by: -1) {
        answer[i] *= suffix
        suffix *= numbers[i]
    }
    return answer
}

print(productsExceptSelf([2, 3, 4, 5]))
print(productsExceptSelf([1, 0, 3, 4]))
print(productsExceptSelf([0, 2, 0]))
print(productsExceptSelf([-1, 2, -3]))
