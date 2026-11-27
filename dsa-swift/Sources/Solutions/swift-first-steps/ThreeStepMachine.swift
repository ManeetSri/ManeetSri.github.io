// Reference solution: The three-step number machine. One constant per step, run top to bottom,
// so the code reads like the machine's instructions. O(1) time and space.

public enum ThreeStepMachine {
    public static func run(_ input: Int) -> Int {
        let added = input + 4
        let tripled = added * 3
        return tripled - 2
    }
}
