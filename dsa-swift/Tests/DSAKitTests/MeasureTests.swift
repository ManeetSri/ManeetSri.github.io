import Testing
import DSAKit

@Suite struct MeasureTests {
    @Test("measure returns the work's result")
    func returnsResult() {
        let total = measure("sum") { (1...100).reduce(0, +) }
        #expect(total == 5050)
    }
}
