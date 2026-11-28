// Generated from src/dsa/design/content/lessons/sd-modelling/sd-modelling-illegal-states.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

enum PaymentState: Equatable {
    case pending
    case authorised(amountPence: Int)
    case declined(reason: String)
}

extension PaymentState: Decodable {
    private enum Keys: String, CodingKey {
        case state
        case amountPence = "amount_pence"
        case reason
    }

    init(from decoder: any Decoder) throws {
        let json = try decoder.container(keyedBy: Keys.self)
        switch try json.decode(String.self, forKey: .state) {
        case "pending":
            self = .pending
        case "authorised":
            self = .authorised(amountPence: try json.decode(Int.self, forKey: .amountPence))
        case "declined":
            self = .declined(reason: try json.decode(String.self, forKey: .reason))
        case let other:
            throw DecodingError.dataCorruptedError(forKey: .state, in: json, debugDescription: "Unknown state \(other)")
        }
    }
}

let payloads = [
    #"{"state": "authorised", "amount_pence": 1999}"#,
    #"{"state": "declined", "reason": "insufficient_funds", "amount_pence": null}"#,
    #"{"state": "authorised"}"#,
    #"{"state": "chargeback"}"#,
]
for json in payloads {
    do {
        print("OK: \(try JSONDecoder().decode(PaymentState.self, from: Data(json.utf8)))")
    } catch DecodingError.keyNotFound(let key, _) {
        print("Rejected: no \(key.stringValue)")
    } catch DecodingError.dataCorrupted(let context) {
        print("Rejected: \(context.debugDescription)")
    } catch {
        print("Rejected: \(error)")
    }
}
