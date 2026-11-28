// Generated from src/dsa/design/content/lessons/sd-swift-design/sd-swift-design-errors.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

enum PaymentError: Error, Equatable {
    case declined(reason: String)
    case insufficientFunds(shortByPence: Int)
    case cardExpired
}

func charge(_ pence: Int, balance: Int, cardExpired: Bool = false) throws(PaymentError) -> Int {
    if cardExpired { throw .cardExpired }
    guard pence > 0 else { throw .declined(reason: "the amount must be positive") }
    guard pence <= balance else { throw .insufficientFunds(shortByPence: pence - balance) }
    return balance - pence
}

// Generic code passes the caller's error type straight through: no `any Error` appears
func logged<T, E: Error>(_ label: String, _ body: () throws(E) -> T) throws(E) -> T {
    do {
        return try body()
    } catch {
        print("[log] \(label) failed: \(error)")
        throw error
    }
}

func checkoutMessage(pence: Int, balance: Int, cardExpired: Bool = false) -> String {
    do throws(PaymentError) {
        let left = try logged("charge") { () throws(PaymentError) -> Int in
            try charge(pence, balance: balance, cardExpired: cardExpired)
        }
        return "Paid. \(left)p left"
    } catch {
        // `error` is a PaymentError, so the switch is exhaustive without a default
        switch error {
        case .declined(let reason): return "Declined: \(reason)"
        case .insufficientFunds(let short): return "You're \(short)p short"
        case .cardExpired: return "Your card has expired"
        }
    }
}

print(checkoutMessage(pence: 1_250, balance: 5_000))
print(checkoutMessage(pence: 6_000, balance: 5_000))
print(checkoutMessage(pence: 1_250, balance: 5_000, cardExpired: true))
