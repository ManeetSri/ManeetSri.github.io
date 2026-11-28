// Reference solution: Server-driven card factory. A dictionary maps each payload type to a maker
// closure, so new types can be registered from anywhere without editing the factory, and unknown
// types are a recoverable error rather than a crash. The factory is a struct, so a copy can be
// extended without changing the original.
import Foundation

public enum CreationalCardFactory {
    public struct Payload: Sendable, Equatable {
        public let type: String
        public let id: String
        public let fields: [String: String]

        public init(type: String, id: String, fields: [String: String] = [:]) {
            self.type = type
            self.id = id
            self.fields = fields
        }
    }

    public protocol Card: Sendable {
        var id: String { get }
    }

    public struct Article: Card, Equatable {
        public let id: String
        public let title: String
        public let url: URL

        public init(id: String, title: String, url: URL) {
            self.id = id
            self.title = title
            self.url = url
        }
    }

    public struct Promo: Card, Equatable {
        public let id: String
        public let headline: String
        public let code: String

        public init(id: String, headline: String, code: String) {
            self.id = id
            self.headline = headline
            self.code = code
        }
    }

    public enum MakeError: Error, Equatable {
        case unknownType(String)
        case missingField(String)
        case invalidField(String)
    }

    public typealias Maker = @Sendable (Payload) throws -> any Card

    public struct Feed: Sendable {
        public let cards: [any Card]
        public let skipped: [String]

        public init(cards: [any Card], skipped: [String]) {
            self.cards = cards
            self.skipped = skipped
        }
    }

    public struct Factory: Sendable {
        private var makers: [String: Maker] = [:]

        public init() {}

        public static func standard() -> Factory {
            var factory = Factory()
            factory.register("article", make: makeArticle)
            factory.register("promo", make: makePromo)
            return factory
        }

        public mutating func register(_ type: String, make: @escaping Maker) {
            makers[type] = make
        }

        public func make(_ payload: Payload) throws -> any Card {
            guard let maker = makers[payload.type] else { throw MakeError.unknownType(payload.type) }
            return try maker(payload)
        }

        public func feed(from payloads: [Payload]) -> Feed {
            var cards: [any Card] = []
            var skipped: [String] = []
            for payload in payloads {
                do {
                    cards.append(try make(payload))
                } catch {
                    skipped.append(payload.id)
                }
            }
            return Feed(cards: cards, skipped: skipped)
        }
    }

    // The standard makers, checked in the order the statement lists the fields

    @Sendable private static func makeArticle(_ payload: Payload) throws -> any Card {
        let title = try required("title", in: payload)
        let link = try required("url", in: payload)
        guard let url = URL(string: link), url.scheme == "https", url.host() != nil else {
            throw MakeError.invalidField("url")
        }
        return Article(id: payload.id, title: title, url: url)
    }

    @Sendable private static func makePromo(_ payload: Payload) throws -> any Card {
        let headline = try required("headline", in: payload)
        let code = try required("code", in: payload)
        return Promo(id: payload.id, headline: headline, code: code.uppercased())
    }

    private static func required(_ field: String, in payload: Payload) throws -> String {
        guard let value = payload.fields[field], !value.isEmpty else { throw MakeError.missingField(field) }
        return value
    }
}
