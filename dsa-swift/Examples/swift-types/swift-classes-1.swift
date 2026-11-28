// Generated from src/dsa/content/lessons/swift-types/swift-classes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

class BankAccount {
    var owner: String
    var balance: Int

    init(owner: String, balance: Int) {
        self.owner = owner
        self.balance = balance
    }

    func deposit(_ amount: Int) {
        balance += amount
    }
}

let account = BankAccount(owner: "Maneet", balance: 100)
account.deposit(50)
print(account.balance)
