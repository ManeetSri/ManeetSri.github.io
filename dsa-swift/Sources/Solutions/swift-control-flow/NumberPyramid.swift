// Reference solution: Number pyramid. The outer loop builds one row at a time; inner loops add the
// padding, the climb up to r and the climb back down. O(height²) time, the size of the output.

public enum NumberPyramid {
    public static func rows(_ height: Int) -> [String] {
        var result: [String] = []
        for row in stride(from: 1, through: height, by: 1) {
            let padding = String(repeating: ".", count: height - row)
            var line = padding
            for digit in 1...row {
                line += "\(digit)"
            }
            for digit in stride(from: row - 1, through: 1, by: -1) {
                line += "\(digit)"
            }
            line += padding
            result.append(line)
        }
        return result
    }
}
