// Reference solution: Switch panel with undo. Arrays are values, so appending the panel stores a
// snapshot, and a stack of saved panels makes undo a popLast(). O(m · s) time and space for
// m operations on s switches (the result alone holds m · s values).

public enum SwitchPanelUndo {
    public static func history(switchCount: Int, operations: [Int]) -> [[Bool]] {
        var panel = Array(repeating: false, count: switchCount)
        var saved: [[Bool]] = []
        var result: [[Bool]] = []
        for operation in operations {
            if operation == -1 {
                if let previous = saved.popLast() {
                    panel = previous
                }
            } else {
                saved.append(panel)
                panel[operation].toggle()
            }
            result.append(panel)
        }
        return result
    }
}
