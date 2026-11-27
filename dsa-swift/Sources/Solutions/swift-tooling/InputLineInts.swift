// Reference solution: Numbers from a line of input. Split on spaces and tabs, convert every piece, and give
// up as soon as one fails. O(length of the input) time and O(number of pieces) space.

public enum InputLineInts {
    public static func integers(in line: String) -> [Int]? {
        var result: [Int] = []
        for piece in line.split(whereSeparator: { $0 == " " || $0 == "\t" }) {
            guard let number = Int(piece) else { return nil }
            result.append(number)
        }
        return result
    }

    public static func readArray(from lines: [String]) -> [Int]? {
        guard let first = lines.first,
              let header = integers(in: first),
              header.count == 1,
              header[0] >= 0 else {
            return nil
        }
        let count = header[0]
        let second = lines.count > 1 ? lines[1] : ""
        guard let numbers = integers(in: second), numbers.count == count else {
            return nil
        }
        return numbers
    }
}
