// Reference solution: Selection with a guaranteed deadline. The pivot is the median of the groups' medians,
// found by calling the selection itself on the medians (a fifth of the input). At least about 3n/10
// elements lie on each side of that pivot, so each round of the three-way quickselect keeps at most
// about 7n/10 of the elements: T(n) ≤ T(n/5) + T(7n/10) + cn, which is O(n) in the worst case.
// O(n) extra space for the medians and the partitions.

public enum MedianOfMediansSelect {
    public static func pivot(of numbers: [Int]) -> Int {
        var medians: [Int] = []
        medians.reserveCapacity(numbers.count / 5 + 1)
        for start in stride(from: 0, to: numbers.count, by: 5) {
            let group = numbers[start..<min(start + 5, numbers.count)].sorted()   // at most 5 elements
            medians.append(group[group.count / 2])
        }
        if medians.count == 1 { return medians[0] }
        return value(atSortedIndex: medians.count / 2, in: medians)            // a fifth of the size
    }

    public static func value(atSortedIndex index: Int, in numbers: [Int]) -> Int {
        var numbers = numbers
        var index = index
        while true {
            if numbers.count <= 5 { return numbers.sorted()[index] }
            let pivot = pivot(of: numbers)
            var smaller: [Int] = []
            var larger: [Int] = []
            for value in numbers {
                if value < pivot {
                    smaller.append(value)
                } else if value > pivot {
                    larger.append(value)
                }
            }
            let equal = numbers.count - smaller.count - larger.count
            if index < smaller.count {
                numbers = smaller                                   // at most about 7n/10 left
            } else if index < smaller.count + equal {
                return pivot
            } else {
                index -= smaller.count + equal
                numbers = larger
            }
        }
    }
}
