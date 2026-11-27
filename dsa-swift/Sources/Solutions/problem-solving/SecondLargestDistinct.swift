// Reference solution: Second largest distinct value. One pass keeping the top two distinct values as
// optionals. O(n) time, O(1) space.

public enum SecondLargestDistinct {
    public static func secondLargest(in numbers: [Int]) -> Int? {
        var largest: Int? = nil
        var second: Int? = nil
        for number in numbers {
            guard let top = largest else {
                largest = number
                continue
            }
            if number > top {
                second = top
                largest = number
            } else if number < top && (second == nil || number > second!) {
                second = number
            }
        }
        return second
    }
}
