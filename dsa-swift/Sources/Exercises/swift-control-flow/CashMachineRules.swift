// Problem: The cash machine's rules (M03 · guard and early exit)

public enum CashMachineRules {
    /// Checks, in order: amount above 0, a multiple of 10, at most `dailyLimit`, at most `balance`.
    /// Returns the first failing rule's message, or "Paid out <amount>. Balance: <left>".
    public static func withdraw(amount: Int, balance: Int, dailyLimit: Int) -> String {
        // Write your solution here, then run:
        // swift test --filter CashMachineRulesTests
        return ""
    }
}
