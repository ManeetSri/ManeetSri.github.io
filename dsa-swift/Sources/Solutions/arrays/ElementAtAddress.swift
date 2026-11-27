// Reference solution: Which element owns this byte? The address formula, base + index × stride, run
// forwards and backwards: dividing the distance from the base by the stride gives the slot, and the
// remainder gives the byte inside it. The negative case is ruled out first, because Swift's division
// rounds towards zero. O(1) time and space.

public enum ElementAtAddress {
    public static func address(ofIndex index: Int, base: Int, stride: Int) -> Int {
        base + index * stride
    }

    public static func owner(ofByte address: Int, base: Int, size: Int, stride: Int, count: Int) -> Int? {
        let distance = address - base
        guard distance >= 0 else { return nil }      // before the array: check before dividing
        let index = distance / stride
        let offset = distance % stride
        guard index < count, offset < size else { return nil }
        return index
    }
}
