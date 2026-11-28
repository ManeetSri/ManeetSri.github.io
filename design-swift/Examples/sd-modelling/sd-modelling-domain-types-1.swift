// Generated from src/dsa/design/content/lessons/sd-modelling/sd-modelling-domain-types.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct EmailAddress: Hashable, Sendable, CustomStringConvertible {
    enum Problem: Error {
        case empty
        case missingAt
        case badDomain
    }

    let rawValue: String

    init(_ text: String) throws {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw Problem.empty }
        let parts = trimmed.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty else { throw Problem.missingAt }
        // Domains are case-insensitive, so normalise them; leave the part before the @ alone
        let domain = parts[1].lowercased()
        guard domain.contains("."), !domain.hasPrefix("."), !domain.hasSuffix("."), !domain.contains(" ") else {
            throw Problem.badDomain
        }
        rawValue = "\(parts[0])@\(domain)"
    }

    var description: String { rawValue }
}

struct PromoCode: Hashable, Sendable {
    let rawValue: String

    /// Codes are 4 to 12 letters or digits; whatever case and spacing people type, they're stored upper case.
    init?(_ text: String) {
        let code = text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard (4...12).contains(code.count),
              code.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber) }) else { return nil }
        rawValue = code
    }
}

for text in [" Sam@Example.COM ", "sam.example.com", "sam@localhost", ""] {
    do {
        print("Email \"\(text)\": \(try EmailAddress(text))")
    } catch {
        print("Email \"\(text)\": rejected, \(error)")
    }
}
for text in [" summer25 ", "50%OFF", "ab"] {
    print("Promo \"\(text)\": \(PromoCode(text)?.rawValue ?? "rejected")")
}
