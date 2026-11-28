// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-static-factories.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct EmailAddress: CustomStringConvertible {
    enum Problem: Error {
        case empty
        case missingAt
        case missingDomain
    }

    let value: String
    var description: String { value }

    init(_ raw: String) throws(Problem) {
        let trimmed = raw.trimmingCharacters(in: .whitespaces).lowercased()
        guard !trimmed.isEmpty else { throw .empty }
        let parts = trimmed.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty else { throw .missingAt }
        guard parts[1].contains("."), !parts[1].hasPrefix("."), !parts[1].hasSuffix(".") else { throw .missingDomain }
        value = trimmed
    }
}

for raw in ["  Maneet@Example.com ", "maneet.example.com", "maneet@localhost", ""] {
    do {
        print("ok:", try EmailAddress(raw))
    } catch {
        print("rejected \"\(raw)\":", error)
    }
}
