// Reference solution: Will it overflow? The reporting methods compute the wrapped result and
// tell us whether the true answer fitted, without ever trapping. O(1) time and space.

public enum OverflowCheck {
    public static func additionOverflows(_ a: Int, _ b: Int) -> Bool {
        a.addingReportingOverflow(b).overflow
    }

    public static func multiplicationOverflows(_ a: Int, _ b: Int) -> Bool {
        a.multipliedReportingOverflow(by: b).overflow
    }
}
