import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ListGcdLcmTests {
    @Test("GCD of the examples", arguments: [
        ([12, 18, 30], 6),
        ([4, 6, 8], 2),
        ([7], 7),
        ([1_000_000_000, 999_999_999], 1),
        ([48, 18], 6),
        ([18, 48], 6),
        ([1071, 462], 21),
        ([100, 100, 100], 100),
        ([17, 34, 51, 85], 17),
        ([6, 10, 15], 1),
    ])
    func gcd(numbers: [Int], expected: Int) {
        #expect(ListGcdLcm.gcd(of: numbers) == expected)
    }

    @Test("LCM of the examples", arguments: [
        ([12, 18, 30], 180),
        ([4, 6, 8], 24),
        ([7], 7),
        ([1], 1),
        ([1_000_000_000, 999_999_999], 999_999_999_000_000_000),
        ([2, 3, 5, 7], 210),
        ([6, 10, 15], 30),
        ([5, 5, 5], 5),
    ])
    func lcm(numbers: [Int], expected: Int) {
        #expect(ListGcdLcm.lcm(of: numbers) == expected)
    }

    @Test("LCM of 1 to 42 just fits; 1 to 43 doesn't")
    func lcmLimit() {
        #expect(ListGcdLcm.lcm(of: Array(1...42)) == 219_060_189_739_591_200)
        #expect(ListGcdLcm.lcm(of: Array(1...43)) == nil)
        #expect(ListGcdLcm.gcd(of: Array(1...43)) == 1)
    }

    @Test("Large values that would overflow if multiplied before dividing")
    func divideFirst() {
        #expect(ListGcdLcm.lcm(of: [1_000_000_000, 1_000_000_000]) == 1_000_000_000)
        #expect(ListGcdLcm.lcm(of: [999_999_937, 999_999_929]) == 999_999_866_000_004_473)
        #expect(ListGcdLcm.lcm(of: [999_999_937, 999_999_929, 999_999_937]) == 999_999_866_000_004_473)
    }

    @Test("Returns nil when the lcm is bigger than Int.max")
    func overflow() {
        #expect(ListGcdLcm.lcm(of: [999_999_937, 999_999_929, 999_999_893]) == nil)
        #expect(ListGcdLcm.lcm(of: [999_999_937, 999_999_929, 999_999_893, 1]) == nil)
    }

    @Test("A long list")
    func longList() {
        let numbers = Array(repeating: 360, count: 100_000) + [84]
        #expect(ListGcdLcm.gcd(of: numbers) == 12)
        #expect(ListGcdLcm.lcm(of: numbers) == 2_520)
    }
}
