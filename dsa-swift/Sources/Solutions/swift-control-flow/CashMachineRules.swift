// Reference solution: The cash machine's rules. One guard per rule, in order, each leaving with
// its message; the success line runs only when all four passed. O(1) time and space.

public enum CashMachineRules {
    public static func withdraw(amount: Int, balance: Int, dailyLimit: Int) -> String {
        guard amount > 0 else {
            return "Enter an amount above zero"
        }
        guard amount % 10 == 0 else {
            return "Amounts must be in tens"
        }
        guard amount <= dailyLimit else {
            return "Over the daily limit"
        }
        guard amount <= balance else {
            return "Not enough money"
        }
        return "Paid out \(amount). Balance: \(balance - amount)"
    }
}
