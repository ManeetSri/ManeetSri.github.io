// Generated from src/dsa/design/content/lessons/sd-principles/sd-principles-dry.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct DeliveryPolicy {
    var freeThresholdPence = 4_000
    var feePence = 399

    func fee(forSubtotal subtotal: Int) -> Int {
        subtotal >= freeThresholdPence ? 0 : feePence
    }

    func bannerText(forSubtotal subtotal: Int) -> String? {
        let remaining = freeThresholdPence - subtotal
        guard remaining > 0 else { return nil }
        return "Spend \(pounds(remaining)) more for free delivery"
    }
}

func pounds(_ pence: Int) -> String {
    String(format: "£%d.%02d", pence / 100, pence % 100)
}

let policy = DeliveryPolicy()
for subtotal in [3_599, 4_000] {
    let banner = policy.bannerText(forSubtotal: subtotal) ?? "Free delivery"
    print("\(pounds(subtotal)): \(banner), delivery \(pounds(policy.fee(forSubtotal: subtotal)))")
}
