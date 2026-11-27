// Problem: Where does the cycle start? (M25 · Fast and slow pointers: middle and cycles)

import DSAKit

public enum CycleEntryPoint {
    /// True if following `next` from `head` loops forever instead of reaching nil.
    public static func hasCycle(_ head: ListNode?) -> Bool {
        // Write your solution here, then run:
        // swift test --filter CycleEntryPointTests
        return false
    }

    /// The first node that's part of the cycle, or nil if the list ends. Don't change the list.
    public static func entry(_ head: ListNode?) -> ListNode? {
        return nil
    }
}
