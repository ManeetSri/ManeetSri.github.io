// Problem: Which element owns this byte? (M18 · Contiguous memory and O(1) indexing)

public enum ElementAtAddress {
    /// Returns the address where element `index` starts, for an array whose elements begin at `base`
    /// and sit `stride` bytes apart. Should be O(1).
    public static func address(ofIndex index: Int, base: Int, stride: Int) -> Int {
        // Write your solution here, then run:
        // swift test --filter ElementAtAddressTests
        return 0
    }

    /// Returns the index of the element whose first `size` bytes include `address`, or nil if the byte
    /// is before the array, after its last element, or padding between `size` and `stride`.
    /// The array has `count` elements starting at `base`, `stride` bytes apart. Should be O(1).
    public static func owner(ofByte address: Int, base: Int, size: Int, stride: Int, count: Int) -> Int? {
        return nil
    }
}
