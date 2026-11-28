// Generated from src/dsa/design/content/lessons/sd-styles/sd-styles-client-server.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

// Version 1.0 of the app knew two payment methods, and decoded them strictly
enum StrictMethod: String, Decodable {
    case card, applePay = "apple_pay"
}

// A tolerant version keeps whatever the server sends, so an old build survives a new case
enum PaymentMethod: Decodable, Equatable {
    case card, applePay
    case unknown(String)

    init(from decoder: any Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        switch raw {
        case "card": self = .card
        case "apple_pay": self = .applePay
        default: self = .unknown(raw)
        }
    }

    var label: String {
        switch self {
        case .card: "card"
        case .applePay: "Apple Pay"
        case .unknown(let raw): "unknown (\(raw))"
        }
    }
}

struct Wallet<Method: Decodable>: Decodable {
    let methods: [Method]
}

// Months later, the server starts sending a method this build has never heard of
let json = Data(#"{ "methods": ["card", "apple_pay", "klarna"] }"#.utf8)

do {
    let wallet = try JSONDecoder().decode(Wallet<StrictMethod>.self, from: json)
    print("Strict: decoded", wallet.methods.count, "methods")
} catch {
    print("Strict: the whole wallet failed to decode")
}

let wallet = try JSONDecoder().decode(Wallet<PaymentMethod>.self, from: json)
print("Tolerant:", wallet.methods.map(\.label))
let usable = wallet.methods.filter { if case .unknown = $0 { false } else { true } }
print("Shown to the user:", usable.count, "of", wallet.methods.count)

// The server also says which builds it still supports. Compare versions numerically, not as text.
let minimumSupported = "2.10.0"
for installed in ["2.9.4", "2.10.0", "2.11.1"] {
    let tooOld = installed.compare(minimumSupported, options: .numeric) == .orderedAscending
    print(installed, tooOld ? "→ ask to update" : "→ fine", "(as plain text: \(installed < minimumSupported ? "older" : "not older"))")
}
