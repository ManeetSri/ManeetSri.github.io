// Reference solution: Gift card wallet. Every rule lives in the actor that owns the balance, and each
// command checks and changes in one method with no `await` inside, so concurrent calls can't interleave.
import Foundation

public enum CouplingGiftCardWallet {
    public enum WalletError: Error, Equatable, Sendable {
        case invalidAmount
        case frozen
        case insufficientFunds(balance: Int)
        case overLimit(maximum: Int)
        case unknownReceipt
        case alreadyRefunded
    }

    public struct Receipt: Equatable, Sendable {
        public let id: Int
        public let amount: Int
        public let remainingBalance: Int

        public init(id: Int, amount: Int, remainingBalance: Int) {
            self.id = id
            self.amount = amount
            self.remainingBalance = remainingBalance
        }
    }

    public actor GiftCard {
        public static let maximumBalance = 50_000

        public private(set) var balance: Int
        public private(set) var isFrozen = false
        private var nextReceiptID = 1
        // Every receipt this card has issued, by ID, and the IDs already refunded
        private var issued: [Int: Receipt] = [:]
        private var refunded: Set<Int> = []

        public init(balance: Int) {
            self.balance = balance
        }

        public func pay(_ amount: Int) throws -> Receipt {
            guard amount > 0 else { throw WalletError.invalidAmount }
            guard !isFrozen else { throw WalletError.frozen }
            guard amount <= balance else { throw WalletError.insufficientFunds(balance: balance) }
            balance -= amount
            let receipt = Receipt(id: nextReceiptID, amount: amount, remainingBalance: balance)
            nextReceiptID += 1
            issued[receipt.id] = receipt
            return receipt
        }

        public func topUp(_ amount: Int) throws -> Int {
            guard amount > 0 else { throw WalletError.invalidAmount }
            guard !isFrozen else { throw WalletError.frozen }
            guard balance + amount <= Self.maximumBalance else { throw WalletError.overLimit(maximum: Self.maximumBalance) }
            balance += amount
            return balance
        }

        public func refund(_ receipt: Receipt) throws -> Int {
            // Only a receipt this card issued, exactly as issued, and only once
            guard issued[receipt.id] == receipt else { throw WalletError.unknownReceipt }
            guard !refunded.contains(receipt.id) else { throw WalletError.alreadyRefunded }
            refunded.insert(receipt.id)
            balance += receipt.amount
            return balance
        }

        public func freeze() {
            isFrozen = true
        }

        public func unfreeze() {
            isFrozen = false
        }
    }
}
