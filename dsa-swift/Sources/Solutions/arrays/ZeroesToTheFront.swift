// Reference solution: Zeroes to the front. The read/write pattern run from the back: numbers[(write + 1)...]
// holds the non-zero values read so far, in their original order. Once every value has been read,
// the slots from 0 to write are filled with zeros. O(n) time, O(1) extra space.

public enum ZeroesToTheFront {
    public static func gather(_ numbers: inout [Int]) {
        var write = numbers.count - 1
        for read in stride(from: numbers.count - 1, through: 0, by: -1) where numbers[read] != 0 {
            numbers[write] = numbers[read]
            write -= 1
        }
        // Everything from index 0 to write is now spare: fill it with zeros
        var index = write
        while index >= 0 {
            numbers[index] = 0
            index -= 1
        }
    }
}
