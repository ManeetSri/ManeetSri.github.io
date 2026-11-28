// Generated from src/dsa/design/content/lessons/sd-modelling/sd-modelling-contracts.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

enum WalletError: Error {
    case insufficientFunds
}

protocol PaymentGateway: Sendable {
    func charge(_ pence: Int) async throws
}

struct SlowGateway: PaymentGateway {
    func charge(_ pence: Int) async throws {
        try await Task.sleep(for: .milliseconds(20))
    }
}

/// - Invariant: `balance` is never negative.
actor Wallet {
    private(set) var balance: Int

    init(balance: Int) {
        self.balance = balance
    }

    /// - Postcondition: on success, `balance` is `amount` lower; on failure, it's unchanged.
    func pay(_ amount: Int, via gateway: some PaymentGateway) async throws {
        guard balance >= amount else { throw WalletError.insufficientFunds }
        balance -= amount              // reserve first: the invariant holds at the await
        do {
            try await gateway.charge(amount)
        } catch {
            balance += amount          // the charge failed, so give it back
            throw error
        }
    }
}

let wallet = Wallet(balance: 5_000)
async let first: Void = wallet.pay(3_000, via: SlowGateway())
async let second: Void = wallet.pay(3_000, via: SlowGateway())
var refused = 0
do { try await first } catch { refused += 1 }
do { try await second } catch { refused += 1 }
print("Payments refused: \(refused) of 2")
print("Balance: £\(await wallet.balance / 100)")
