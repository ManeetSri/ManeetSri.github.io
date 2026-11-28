import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct AccountWithdrawalRulesTests {
    typealias Account = AccountWithdrawalRules.Account
    typealias OverdraftAccount = AccountWithdrawalRules.OverdraftAccount
    typealias SavingsAccount = AccountWithdrawalRules.SavingsAccount

    @Test("A plain account can't go below zero")
    func plainRule() {
        let account = Account(owner: "Asha", balance: 100)
        #expect(account.withdraw(30))
        #expect(account.balance == 70)
        #expect(!account.withdraw(80))
        #expect(account.balance == 70)
        #expect(account.withdraw(70))
        #expect(account.balance == 0)
        #expect(!account.withdraw(1))
    }

    @Test("Zero and negative amounts are refused by every account")
    func nonPositiveAmounts() {
        let accounts: [Account] = [
            Account(owner: "Asha", balance: 100),
            OverdraftAccount(owner: "Ravi", balance: 100, limit: 50),
            SavingsAccount(owner: "Mina", balance: 100),
        ]
        for account in accounts {
            #expect(!account.withdraw(0))
            #expect(!account.withdraw(-5))
            #expect(account.balance == 100)
        }
    }

    @Test("An overdraft account may go down to minus its limit")
    func overdraft() {
        let account = OverdraftAccount(owner: "Ravi", balance: 20, limit: 50)
        #expect(account.withdraw(60))
        #expect(account.balance == -40)
        #expect(account.withdraw(10))
        #expect(account.balance == -50)
        #expect(!account.withdraw(1))
        #expect(account.balance == -50)
        account.deposit(100)
        #expect(account.withdraw(100))
        #expect(account.balance == -50)
    }

    @Test("A savings account allows three withdrawals a month")
    func savingsLimit() {
        let account = SavingsAccount(owner: "Mina", balance: 1_000)
        #expect(account.withdraw(10))
        #expect(account.withdraw(10))
        #expect(account.withdraw(10))
        #expect(account.withdrawalsThisMonth == 3)
        #expect(!account.withdraw(10))
        #expect(account.balance == 970)
        account.startNewMonth()
        #expect(account.withdrawalsThisMonth == 0)
        #expect(account.withdraw(10))
        #expect(account.balance == 960)
    }

    @Test("A savings account still follows the plain rule, and refusals don't count")
    func savingsPlainRule() {
        let account = SavingsAccount(owner: "Mina", balance: 50)
        #expect(!account.withdraw(100))
        #expect(account.withdrawalsThisMonth == 0)
        #expect(account.withdraw(20))
        #expect(account.withdraw(20))
        #expect(!account.withdraw(20))
        #expect(account.withdrawalsThisMonth == 2)
        #expect(account.withdraw(10))
        #expect(account.balance == 0)
        account.deposit(500)
        #expect(!account.withdraw(10))
        #expect(account.balance == 500)
    }

    @Test("Each kind of account names itself")
    func kinds() {
        let accounts: [Account] = [
            Account(owner: "Asha", balance: 0),
            OverdraftAccount(owner: "Ravi", balance: 0, limit: 10),
            SavingsAccount(owner: "Mina", balance: 0),
        ]
        #expect(accounts.map { $0.kind() } == ["Account", "Overdraft", "Savings"])
    }

    @Test("Statements use the real kind of account")
    func statements() {
        let plain = Account(owner: "Asha", balance: 100)
        _ = plain.withdraw(30)
        let overdraft = OverdraftAccount(owner: "Ravi", balance: 20, limit: 100)
        _ = overdraft.withdraw(60)
        let savings = SavingsAccount(owner: "Mina", balance: 1_000)
        _ = savings.withdraw(30)
        let accounts: [Account] = [plain, overdraft, savings]
        #expect(accounts.map { $0.statement() } == [
            "Account: Asha has 70",
            "Overdraft: Ravi has -40",
            "Savings: Mina has 970",
        ])
    }

    @Test("withdrawFromEach applies each account's own rule")
    func withdrawFromEach() {
        let plain = Account(owner: "Asha", balance: 40)
        let overdraft = OverdraftAccount(owner: "Ravi", balance: 0, limit: 100)
        let savings = SavingsAccount(owner: "Mina", balance: 60)
        let accounts: [Account] = [plain, overdraft, savings]

        #expect(AccountWithdrawalRules.withdrawFromEach(accounts, amount: 50) == 2)
        #expect(plain.balance == 40)
        #expect(overdraft.balance == -50)
        #expect(savings.balance == 10)

        #expect(AccountWithdrawalRules.withdrawFromEach(accounts, amount: 50) == 1)
        #expect(overdraft.balance == -100)
        #expect(savings.balance == 10)

        #expect(AccountWithdrawalRules.withdrawFromEach([], amount: 50) == 0)
    }
}
