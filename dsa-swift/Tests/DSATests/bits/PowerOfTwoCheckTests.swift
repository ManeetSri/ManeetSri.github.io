import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PowerOfTwoCheckTests {
    @Test("Every power of two from 2⁰ to 2⁶²", arguments: 0...62)
    func powers(k: Int) {
        #expect(PowerOfTwoCheck.isPowerOfTwo(1 << k))
    }

    @Test("The neighbours of a power of two aren't powers of two", arguments: 2...62)
    func neighbours(k: Int) {
        #expect(!PowerOfTwoCheck.isPowerOfTwo((1 << k) - 1))
        #expect(!PowerOfTwoCheck.isPowerOfTwo((1 << k) + 1))
    }

    @Test("Other positive numbers", arguments: [3, 6, 12, 96, 1_000, 1_000_000])
    func others(n: Int) {
        #expect(!PowerOfTwoCheck.isPowerOfTwo(n))
    }

    @Test("Zero and negative numbers are never powers of two", arguments: [0, -1, -2, -8, -1_024, Int.min])
    func notPositive(n: Int) {
        #expect(!PowerOfTwoCheck.isPowerOfTwo(n))
    }

    @Test("Int.max isn't a power of two")
    func largest() {
        #expect(!PowerOfTwoCheck.isPowerOfTwo(Int.max))
    }
}
