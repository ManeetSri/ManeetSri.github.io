// Generated from src/dsa/design/content/lessons/sd-modelling/sd-modelling-domain-types.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

let prices = [0.10, 0.20, 0.30]
let total = prices.reduce(0, +)
print("Double total: \(total), equals 0.6? \(total == 0.6)")
print("£19.99 in pence, via Double: \(Int(19.99 * 100))")
print("Decimal made from a Double: \(Decimal(19.99) * 100)")

let pence = [10, 20, 30].reduce(0, +)
print("Integer pence: \(pence), equals 60? \(pence == 60)")
let price = Decimal(string: "19.99")!
print("Decimal from a string: \(price * 100)")
print("Shown to the user: \(price.formatted(.currency(code: "GBP").locale(Locale(identifier: "en_GB"))))")
