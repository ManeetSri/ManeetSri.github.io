import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ProductExceptSelfTests {
    @Test("Multiplies everything else", arguments: [
        ([2, 3, 4, 5], [60, 40, 30, 24]),
        ([-1, 2, -3], [-6, 3, -2]),
        ([3, 7], [7, 3]),
        ([1, 1, 1, 1], [1, 1, 1, 1]),
        ([-2, -2, -2], [4, 4, 4]),
    ])
    func products(numbers: [Int], expected: [Int]) {
        #expect(ProductExceptSelf.products(of: numbers) == expected)
    }

    @Test("Handles zeros without dividing", arguments: [
        ([1, 0, 3, 4], [0, 12, 0, 0]),
        ([0, 2, 0], [0, 0, 0]),
        ([4, 0, 5, 0], [0, 0, 0, 0]),
        ([0, 5], [5, 0]),
        ([0], [1]),
    ])
    func zeros(numbers: [Int], expected: [Int]) {
        #expect(ProductExceptSelf.products(of: numbers) == expected)
    }

    @Test("A single element's product of the others is the empty product, 1")
    func single() {
        #expect(ProductExceptSelf.products(of: [9]) == [1])
    }

    @Test("An empty array gives an empty array")
    func empty() {
        #expect(ProductExceptSelf.products(of: []) == [])
    }

    @Test("Matches a brute force on many small arrays")
    func matchesBruteForce() {
        var firstMismatch: [Int]? = nil
        for seed in 0..<200 {
            let numbers = (0..<(seed % 8 + 1)).map { ($0 * 5 + seed * 3) % 7 - 3 }
            let expected = numbers.indices.map { i in
                numbers.indices.reduce(1) { product, j in j == i ? product : product * numbers[j] }
            }
            if ProductExceptSelf.products(of: numbers) != expected {
                firstMismatch = firstMismatch ?? numbers
            }
        }
        #expect(firstMismatch == nil, "the first array where the answer differs from the brute force")
    }

    @Test("Stays fast on 100,000 numbers")
    func large() throws {
        let n = 100_000
        var numbers = (0..<n).map { $0 % 3 == 0 ? -1 : 1 }
        numbers[500] = 2
        numbers[77_777] = 3
        let total = numbers.reduce(1, *)
        let result = ProductExceptSelf.products(of: numbers)
        #expect(result.count == n)
        #expect(result == numbers.map { total / $0 })   // division is fine here: there are no zeros

        // numbers[1_234] was 1, so with it replaced by 0 the other elements still multiply to `total`
        numbers[1_234] = 0
        let withZero = ProductExceptSelf.products(of: numbers)
        try #require(withZero.count == n)
        #expect(withZero.indices.allSatisfy { $0 == 1_234 || withZero[$0] == 0 })
        #expect(withZero[1_234] == total)
    }
}
