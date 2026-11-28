// Generated from src/dsa/content/lessons/swift-types/swift-value-vs-reference.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct WalletValue {
    var coins = 10
}

class WalletObject {
    var coins = 10
}

func spendAll(_ wallet: WalletObject) {
    wallet.coins = 0
}

func spentVersion(of wallet: WalletValue) -> WalletValue {
    var copy = wallet
    copy.coins = 0
    return copy
}

let shared = WalletObject()
spendAll(shared)
print("Object after the call:", shared.coins)

let mine = WalletValue()
let changed = spentVersion(of: mine)
print("Value after the call:", mine.coins)
print("Returned copy:", changed.coins)
