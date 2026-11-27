// Problem: Value or reference? (M09 · Value vs reference semantics)

public enum ValueReferenceSimulator {
    /// Runs `commands` as if every variable held a struct (`usingClasses` false) or a class instance
    /// (`usingClasses` true) with one Int property, and returns the values the "show" commands report.
    ///
    /// - "new a 5": `a` gets a brand-new thing holding 5.
    /// - "copy b a": `b = a`.
    /// - "add b 3": adds 3 to the value of the thing `b` holds (the amount may be negative).
    /// - "show a": reports the value of the thing `a` holds.
    public static func run(_ commands: [String], usingClasses: Bool) -> [Int] {
        // Write your solution here, then run:
        // swift test --filter ValueReferenceSimulatorTests
        return []
    }
}
