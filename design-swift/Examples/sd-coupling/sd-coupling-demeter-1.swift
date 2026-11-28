// Generated from src/dsa/design/content/lessons/sd-coupling/sd-coupling-demeter.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

enum PaymentError: Error {
    case insufficientFunds
    case frozen
}

actor GiftCard {
    private var balancePence: Int
    private var isFrozen = false

    init(balancePence: Int) {
        self.balancePence = balancePence
    }

    var balance: Int { balancePence }

    // Tell: the check and the change run together, with no await between them
    func pay(_ pence: Int) throws(PaymentError) {
        guard !isFrozen else { throw .frozen }
        guard pence <= balancePence else { throw .insufficientFunds }
        balancePence -= pence
    }
}

func tapPay(_ pence: Int, on card: GiftCard) async -> Bool {
    do {
        try await card.pay(pence)
        return true
    } catch {
        return false
    }
}

let card = GiftCard(balancePence: 500)

// Two taps on "Pay" arrive at the same moment
async let first = tapPay(500, on: card)
async let second = tapPay(500, on: card)
let results = await [first, second]

print("Paid: \(results.filter { $0 }.count), declined: \(results.filter { !$0 }.count)")
print("Balance: \(await card.balance)p")
