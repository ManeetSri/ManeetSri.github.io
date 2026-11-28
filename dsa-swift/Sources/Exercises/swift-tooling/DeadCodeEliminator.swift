// Problem: Deleting unused work (M12 · Debug vs release builds)

public enum DeadCodeEliminator {
    /// Removes the lines of `program` whose work is never used, like an optimiser, and returns the rest
    /// in their original order.
    ///
    /// Each line is "print v" or an assignment: "x = a", "x = a + b", "x = a - b" or "x = a * b",
    /// where each operand is a variable name or a whole number. Every print is kept. An assignment is
    /// kept only if a kept line later reads the value it stores, before the variable is assigned again.
    public static func optimise(_ program: [String]) -> [String] {
        // Write your solution here, then run:
        // swift test --filter DeadCodeEliminatorTests
        return []
    }
}
