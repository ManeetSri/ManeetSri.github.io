// Reference solution: Missing and doubled numbers. Cyclic sort sends every value v to index v − 1;
// a second copy finds its home taken by an equal value and stays put, in the home of some missing
// value. Afterwards each index i that doesn't hold i + 1 means i + 1 is missing, and the value
// sitting there is a spare copy of a doubled value. O(n) time, O(1) extra space besides the result.

public enum MissingAndDoubled {
    public static func find(in numbers: inout [Int]) -> (missing: [Int], doubled: [Int]) {
        var i = 0
        while i < numbers.count {
            let home = numbers[i] - 1
            if numbers[i] != numbers[home] {
                numbers.swapAt(i, home)
            } else {
                i += 1                                // home, or its home already holds a copy
            }
        }
        var missing: [Int] = []
        var doubled: [Int] = []
        for index in numbers.indices where numbers[index] != index + 1 {
            missing.append(index + 1)
            doubled.append(numbers[index])
        }
        return (missing, doubled)
    }
}
