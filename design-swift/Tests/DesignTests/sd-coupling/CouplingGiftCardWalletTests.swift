import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias GiftCard = CouplingGiftCardWallet.GiftCard
private typealias WalletError = CouplingGiftCardWallet.WalletError
private typealias Receipt = CouplingGiftCardWallet.Receipt

@Suite struct CouplingGiftCardWalletTests {
    @Test("Paying takes from the balance and returns numbered receipts")
    func pay() async throws {
        let card = GiftCard(balance: 2_000)
        #expect(try await card.pay(350) == Receipt(id: 1, amount: 350, remainingBalance: 1_650))
        #expect(try await card.pay(1_000) == Receipt(id: 2, amount: 1_000, remainingBalance: 650))
        #expect(await card.balance == 650)
    }

    @Test("Paying more than the balance is refused and changes nothing")
    func insufficientFunds() async throws {
        let card = GiftCard(balance: 2_000)
        _ = try await card.pay(1_500)
        await #expect(throws: WalletError.insufficientFunds(balance: 500)) {
            try await card.pay(501)
        }
        #expect(await card.balance == 500)
        #expect(try await card.pay(500).remainingBalance == 0)
    }

    @Test("Zero and negative amounts are refused", arguments: [0, -5])
    func invalidAmounts(amount: Int) async {
        let card = GiftCard(balance: 1_000)
        await #expect(throws: WalletError.invalidAmount) { try await card.pay(amount) }
        await #expect(throws: WalletError.invalidAmount) { try await card.topUp(amount) }
        #expect(await card.balance == 1_000)
    }

    @Test("A frozen card can't pay or be topped up until it's unfrozen")
    func frozen() async throws {
        let card = GiftCard(balance: 1_000)
        await card.freeze()
        #expect(await card.isFrozen)
        await #expect(throws: WalletError.frozen) { try await card.pay(100) }
        await #expect(throws: WalletError.frozen) { try await card.topUp(100) }
        await card.unfreeze()
        #expect(await !card.isFrozen)
        #expect(try await card.pay(100).remainingBalance == 900)
    }

    @Test("Checks run in order: an invalid amount is reported before a frozen card")
    func checkOrder() async {
        let card = GiftCard(balance: 1_000)
        await card.freeze()
        await #expect(throws: WalletError.invalidAmount) { try await card.pay(0) }
        await card.unfreeze()
        await #expect(throws: WalletError.insufficientFunds(balance: 1_000)) { try await card.pay(5_000) }
    }

    @Test("Top-ups can fill the card to its limit, but not past it")
    func topUpLimit() async throws {
        let card = GiftCard(balance: 45_000)
        #expect(try await card.topUp(4_000) == 49_000)
        await #expect(throws: WalletError.overLimit(maximum: 50_000)) { try await card.topUp(1_001) }
        #expect(await card.balance == 49_000)
        #expect(try await card.topUp(1_000) == GiftCard.maximumBalance)
    }

    @Test("A receipt can be refunded once, on the card that issued it")
    func refunds() async throws {
        let card = GiftCard(balance: 1_000)
        let receipt = try await card.pay(400)
        await card.freeze()
        #expect(try await card.refund(receipt) == 1_000)
        await #expect(throws: WalletError.alreadyRefunded) { try await card.refund(receipt) }

        let other = GiftCard(balance: 5_000)
        let otherReceipt = try await other.pay(2_500)
        await #expect(throws: WalletError.unknownReceipt) { try await card.refund(otherReceipt) }
        await #expect(throws: WalletError.unknownReceipt) {
            try await card.refund(Receipt(id: 99, amount: 100, remainingBalance: 0))
        }
        #expect(await card.balance == 1_000)
    }

    @Test("A hundred simultaneous payments never overspend the card")
    func concurrentPayments() async {
        let card = GiftCard(balance: 5_000)
        let paid = await withTaskGroup(of: Bool.self) { group in
            for _ in 0..<100 {
                group.addTask { (try? await card.pay(100)) != nil }
            }
            return await group.reduce(0) { count, succeeded in count + (succeeded ? 1 : 0) }
        }
        #expect(paid == 50)
        #expect(await card.balance == 0)
    }
}
