// Problem: A lock that keeps its secret (M09 · Access control)

public enum GuardedPinLock {
    public struct Lock {
        // Nothing outside Lock can read the PIN, and only Lock's own methods can change the other two.
        private var pin: String
        public private(set) var isOpen = false
        public private(set) var attemptsLeft = 3

        /// A closed lock with this PIN, or nil unless the PIN is exactly four of the digits 0 to 9.
        public init?(pin: String) {
            // Write your solution here, then run:
            // swift test --filter GuardedPinLockTests
            return nil
        }

        /// True once every attempt is used up. A blocked lock stays blocked.
        public var isBlocked: Bool {
            return false
        }

        /// Tries `guess`. A blocked lock ignores every guess and returns false. The right PIN opens the
        /// lock, restores all three attempts and returns true. A wrong PIN uses up an attempt, leaves
        /// the lock closed and returns false.
        public mutating func enter(_ guess: String) -> Bool {
            return false
        }

        /// Closes the lock.
        public mutating func close() {
        }

        /// Changes the PIN to `newPin` if the lock is open and `newPin` is a valid PIN.
        /// Returns whether the PIN changed.
        public mutating func changePin(to newPin: String) -> Bool {
            return false
        }
    }
}
