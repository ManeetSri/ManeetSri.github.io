import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct FewestSquarePanelsTests {
    /// The answer from number theory instead of DP. Lagrange: every number is a sum of at most four
    /// squares. Legendre: it needs four exactly when it has the form 4^a · (8b + 7).
    private func byTheorem(_ n: Int) -> Int {
        func isSquare(_ value: Int) -> Bool {
            var root = 0
            while (root + 1) * (root + 1) <= value {
                root += 1
            }
            return root * root == value
        }
        if isSquare(n) {
            return 1
        }
        var a = 1
        while a * a <= n {
            if isSquare(n - a * a) {
                return 2
            }
            a += 1
        }
        var rest = n
        while rest % 4 == 0 {
            rest /= 4
        }
        return rest % 8 == 7 ? 4 : 3
    }

    @Test("Examples and small cases", arguments: [
        (12, 3),
        (13, 2),
        (16, 1),
        (7, 4),
        (1, 1),
        (2, 2),
        (43, 3),
        (28, 4),
    ])
    func examples(tiles: Int, expected: Int) {
        #expect(FewestSquarePanels.fewestPanels(tiles: tiles) == expected)
    }

    @Test("Every tile count from 1 to 400 agrees with Lagrange and Legendre")
    func everySmallCount() {
        for tiles in 1...400 {
            #expect(FewestSquarePanels.fewestPanels(tiles: tiles) == byTheorem(tiles), "tiles \(tiles)")
        }
    }

    @Test("Large tile counts", arguments: [10_000, 9_999, 9_998, 9_997, 9_973, 7_168, 8_191, 6_125, 5_000])
    func large(tiles: Int) {
        // About a million steps for the DP. Trying every combination of squares would never finish.
        #expect(FewestSquarePanels.fewestPanels(tiles: tiles) == byTheorem(tiles))
    }
}
