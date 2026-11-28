// Problem: Withdrawal rules (M09 · Classes, inheritance and final)

public enum AccountWithdrawalRules {
    /// A plain account. Subclasses change the rule for withdrawing.
    public class Account {
        public let owner: String
        public var balance: Int

        public init(owner: String, balance: Int) {
            self.owner = owner
            self.balance = balance
        }

        /// Adds `amount` to the balance. Zero or negative amounts are ignored.
        public func deposit(_ amount: Int) {
            if amount > 0 {
                balance += amount
            }
        }

        // Write your solution here, then run:
        // swift test --filter AccountWithdrawalRulesTests

        /// A short name for this kind of account: "Account" here.
        public func kind() -> String {
            return ""
        }

        /// Takes `amount` out of the balance if this account's rule allows it, and returns whether it did.
        /// Plain rule: `amount` must be positive and no more than the balance.
        public func withdraw(_ amount: Int) -> Bool {
            return false
        }

        /// "<kind>: <owner> has <balance>", for example "Account: Asha has 70".
        public func statement() -> String {
            return ""
        }
    }

    /// An account that may go below zero, as far as minus `limit`.
    public class OverdraftAccount: Account {
        public let limit: Int

        public init(owner: String, balance: Int, limit: Int) {
            self.limit = limit
            super.init(owner: owner, balance: balance)
        }

        // Override kind() to return "Overdraft", and withdraw(_:) to allow a positive amount
        // as long as the balance afterwards is at least -limit.
    }

    /// A savings account: at most three successful withdrawals a month, each following the plain rule.
    public final class SavingsAccount: Account {
        /// How many withdrawals have succeeded since the month started.
        public var withdrawalsThisMonth = 0

        // Override kind() to return "Savings", and withdraw(_:) to refuse once three withdrawals have
        // succeeded this month. Refused withdrawals don't count.

        /// Starts a new month, so three more withdrawals are allowed.
        public func startNewMonth() {
        }
    }

    /// Tries to withdraw `amount` from every account in turn, each with its own rule,
    /// and returns how many of the withdrawals succeeded.
    public static func withdrawFromEach(_ accounts: [Account], amount: Int) -> Int {
        return 0
    }
}
