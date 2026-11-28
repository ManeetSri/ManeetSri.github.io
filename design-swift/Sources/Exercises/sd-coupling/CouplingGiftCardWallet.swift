// Kata: Gift card wallet (D03 · The Law of Demeter and tell, don't ask)
import DesignKit
import Foundation

public enum CouplingGiftCardWallet {
    /// Why a command was refused
    public enum WalletError: Error, Equatable, Sendable {
        /// The amount is zero or negative
        case invalidAmount
        /// The card is frozen, so it can't pay or be topped up
        case frozen
        /// The payment is more than the card holds. Carries the balance at the time.
        case insufficientFunds(balance: Int)
        /// The top-up would take the balance above the card's limit. Carries the limit.
        case overLimit(maximum: Int)
        /// This card didn't issue the receipt
        case unknownReceipt
        /// The receipt has been refunded already
        case alreadyRefunded
    }

    /// Proof of one payment: its number on this card (1, 2, 3… in order), the amount and the balance after it
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

    /// A gift card that owns its balance and its rules. Callers tell it what to do; nobody else changes
    /// the balance. All amounts are in pence.
    public actor GiftCard {
        /// No card may hold more than £500
        public static let maximumBalance = 50_000

        /// Starts with `balance`, between 0 and `maximumBalance`, not frozen
        public init(balance: Int) {
            // Write your solution here
        }

        /// What the card holds now. Reading it is fine; changing it happens only through the commands.
        public var balance: Int {
            // Write your solution here
            0
        }

        public var isFrozen: Bool {
            // Write your solution here
            false
        }

        /// Takes `amount` from the balance and returns a receipt. Checks, in this order: the amount is
        /// positive, the card isn't frozen, the balance covers it.
        public func pay(_ amount: Int) throws -> Receipt {
            // Write your solution here, then run:
            // swift test --filter CouplingGiftCardWalletTests
            throw Unimplemented()
        }

        /// Adds `amount` and returns the new balance. Checks, in this order: the amount is positive, the card
        /// isn't frozen, the new balance stays within `maximumBalance`.
        public func topUp(_ amount: Int) throws -> Int {
            throw Unimplemented()
        }

        /// Gives a payment back and returns the new balance. Checks, in this order: this card issued exactly
        /// this receipt, and it hasn't been refunded. Refunds work even while the card is frozen, and the
        /// limit doesn't apply: it's the customer's own money coming back.
        public func refund(_ receipt: Receipt) throws -> Int {
            throw Unimplemented()
        }

        public func freeze() {
            // Write your solution here
        }

        public func unfreeze() {
            // Write your solution here
        }
    }
}
