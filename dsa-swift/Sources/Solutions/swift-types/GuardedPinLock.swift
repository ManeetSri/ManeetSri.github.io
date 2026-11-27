// Reference solution: A lock that keeps its secret. The PIN is private and the state is private(set), so
// the only way to change a Lock is through its methods, which enforce every rule. Each method is O(1).

public enum GuardedPinLock {
    public struct Lock {
        private var pin: String
        public private(set) var isOpen = false
        public private(set) var attemptsLeft = 3

        public init?(pin: String) {
            guard Lock.isValid(pin) else {
                return nil
            }
            self.pin = pin
        }

        public var isBlocked: Bool {
            attemptsLeft == 0
        }

        private static func isValid(_ pin: String) -> Bool {
            pin.count == 4 && pin.allSatisfy { ("0"..."9").contains($0) }
        }

        public mutating func enter(_ guess: String) -> Bool {
            guard !isBlocked else {
                return false
            }
            if guess == pin {
                isOpen = true
                attemptsLeft = 3
                return true
            }
            isOpen = false
            attemptsLeft -= 1
            return false
        }

        public mutating func close() {
            isOpen = false
        }

        public mutating func changePin(to newPin: String) -> Bool {
            guard isOpen, Lock.isValid(newPin) else {
                return false
            }
            pin = newPin
            return true
        }
    }
}
