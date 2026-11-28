import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct FirstLastPositionTests {
    static let readings = [1, 3, 3, 3, 5, 8, 8, 9]

    @Test("Finds the run of copies", arguments: [
        (3, 1...3), (8, 5...6), (1, 0...0), (9, 7...7), (5, 4...4),
    ])
    func finds(target: Int, expected: ClosedRange<Int>) {
        #expect(FirstLastPosition.span(of: target, in: Self.readings) == expected)
    }

    @Test("Missing values give nil", arguments: [0, 2, 4, 6, 7, 10, Int.min, Int.max])
    func missing(target: Int) {
        #expect(FirstLastPosition.span(of: target, in: Self.readings) == nil)
    }

    @Test("Empty, single and all-equal arrays")
    func smallCases() {
        #expect(FirstLastPosition.span(of: 3, in: []) == nil)
        #expect(FirstLastPosition.span(of: 3, in: [3]) == 0...0)
        #expect(FirstLastPosition.span(of: 4, in: [3]) == nil)
        #expect(FirstLastPosition.span(of: 7, in: [7, 7, 7, 7, 7]) == 0...4)
        #expect(FirstLastPosition.span(of: 7, in: [7, 7]) == 0...1)
        #expect(FirstLastPosition.span(of: 6, in: [7, 7]) == nil)
    }

    @Test("Runs at the very start and end")
    func edges() {
        #expect(FirstLastPosition.span(of: -2, in: [-2, -2, -2, 0, 4]) == 0...2)
        #expect(FirstLastPosition.span(of: 4, in: [-2, 0, 4, 4, 4]) == 2...4)
    }

    @Test("Matches a linear scan on every small array")
    func exhaustive() {
        var firstMismatch: String? = nil
        // Every non-decreasing array of up to 7 values drawn from 0...3
        func check(_ numbers: [Int]) {
            for target in -1...4 {
                let expected: ClosedRange<Int>? = numbers.firstIndex(of: target).map { $0...numbers.lastIndex(of: target)! }
                if FirstLastPosition.span(of: target, in: numbers) != expected {
                    firstMismatch = firstMismatch ?? "target \(target) in \(numbers)"
                }
            }
        }
        func build(_ numbers: [Int]) {
            check(numbers)
            guard numbers.count < 7 else { return }
            for next in (numbers.last ?? 0)...3 {
                build(numbers + [next])
            }
        }
        build([])
        #expect(firstMismatch == nil, "the first input where the answer is wrong")
    }

    @Test("10,000 searches through runs of 100,000 copies")
    func large() {
        // Ten values, each repeated 100,000 times: scanning along a run would take far too long
        let numbers = (0..<1_000_000).map { ($0 / 100_000) * 10 }
        var wrong = 0
        for query in 0..<10_000 {
            let target = query % 21 * 5 - 5                       // -5, 0, 5, …, 95
            let expected: ClosedRange<Int>? = target >= 0 && target % 10 == 0 && target <= 90
                ? (target / 10 * 100_000)...(target / 10 * 100_000 + 99_999)
                : nil
            if FirstLastPosition.span(of: target, in: numbers) != expected {
                wrong += 1
            }
        }
        #expect(wrong == 0)
    }
}
