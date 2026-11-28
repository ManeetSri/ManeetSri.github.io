// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-object-pools.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

let ukLocale = Locale(identifier: "en_GB")
let utc = TimeZone(identifier: "UTC")!

let orderDate = Date(timeIntervalSince1970: 1_750_000_000)
let dateStyle = Date.FormatStyle(date: .abbreviated, time: .omitted, locale: ukLocale, timeZone: utc)
let priceStyle = Decimal.FormatStyle.Currency(code: "GBP", locale: ukLocale)

print(orderDate.formatted(dateStyle))
print(Decimal(string: "1234.5")!.formatted(priceStyle))
print((0.256).formatted(.percent.precision(.fractionLength(1)).locale(ukLocale)))
