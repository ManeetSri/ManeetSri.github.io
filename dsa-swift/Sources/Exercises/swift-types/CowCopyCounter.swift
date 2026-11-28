// Problem: Counting copy-on-write copies (M09 · Copy-on-write explained)

public enum CowCopyCounter {
    /// Runs `commands` on array variables that use copy-on-write, and returns the total number of
    /// elements copied.
    ///
    /// - "new a 3": `a` becomes a new array of 3 elements with storage of its own.
    /// - "copy b a": `b = a`, so `b` shares `a`'s storage.
    /// - "append a", "write a", "remove a": writes that add one element, change one in place,
    ///   or remove the last one. A write to storage that another variable shares first gives
    ///   this variable its own copy, which copies every element the storage holds.
    /// - "read a": reads an element.
    public static func elementsCopied(by commands: [String]) -> Int {
        // Write your solution here, then run:
        // swift test --filter CowCopyCounterTests
        return 0
    }
}
