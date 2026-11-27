// Reference solution: Withdrawal rules. Each subclass overrides only the rule that differs and reuses the
// rest through `super`, so `statement()` is written once. Every method is O(1); `withdrawFromEach` is O(n).

public enum AccountWithdrawalRules {
    public class Account {
        public let owner: String
        public var balance: Int

        public init(owner: String, balance: Int) {
            self.owner = owner
            self.balance = balance
        }

        public func deposit(_ amount: Int) {
            if amount > 0 {
                balance += amount
            }
        }

        public func kind() -> String {
            "Account"
        }

        public func withdraw(_ amount: Int) -> Bool {
            guard amount > 0, amount <= balance else {
                return false
            }
            balance -= amount
            return true
        }

        // kind() runs the version belonging to the real object, so subclasses get their own label for free
        public func statement() -> String {
            "\(kind()): \(owner) has \(balance)"
        }
    }

    public class OverdraftAccount: Account {
        public let limit: Int

        public init(owner: String, balance: Int, limit: Int) {
            self.limit = limit
            super.init(owner: owner, balance: balance)
        }

        override public func kind() -> String {
            "Overdraft"
        }

        override public func withdraw(_ amount: Int) -> Bool {
            guard amount > 0, balance - amount >= -limit else {
                return false
            }
            balance -= amount
            return true
        }
    }

    public final class SavingsAccount: Account {
        public var withdrawalsThisMonth = 0

        override public func kind() -> String {
            "Savings"
        }

        // Adds the monthly limit on top of the plain rule, which super.withdraw still checks
        override public func withdraw(_ amount: Int) -> Bool {
            guard withdrawalsThisMonth < 3 else {
                return false
            }
            if super.withdraw(amount) {
                withdrawalsThisMonth += 1
                return true
            }
            return false
        }

        public func startNewMonth() {
            withdrawalsThisMonth = 0
        }
    }

    // One call, three behaviours: each account applies its own rule
    public static func withdrawFromEach(_ accounts: [Account], amount: Int) -> Int {
        var succeeded = 0
        for account in accounts where account.withdraw(amount) {
            succeeded += 1
        }
        return succeeded
    }
}
