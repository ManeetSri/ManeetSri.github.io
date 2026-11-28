// Kata: Server-driven card factory (D10 · Factory method)
import DesignKit
import Foundation

public enum CreationalCardFactory {
    /// One component of a server-driven feed, as the server sent it
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

    /// Anything the feed can show
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

    /// Why a payload couldn't become a card
    public enum MakeError: Error, Equatable {
        case unknownType(String)
        case missingField(String)
        case invalidField(String)
    }

    /// Turns a payload into a card, or throws if the payload can't be one
    public typealias Maker = @Sendable (Payload) throws -> any Card

    /// What a whole feed produced: the cards, in order, and the ids of the payloads that were skipped
    public struct Feed: Sendable {
        public let cards: [any Card]
        public let skipped: [String]

        public init(cards: [any Card], skipped: [String]) {
            self.cards = cards
            self.skipped = skipped
        }
    }

    /// Makes cards from payloads, using one maker per payload type
    public struct Factory: Sendable {
        /// A factory that knows no types yet
        public init() {}

        /// A factory with makers for "article" and "promo" already registered
        public static func standard() -> Factory {
            // Write your solution here, then run:
            // swift test --filter CreationalCardFactoryTests
            Factory()
        }

        /// Adds a maker for `type`, replacing any maker already registered for it
        public mutating func register(_ type: String, make: @escaping Maker) {}

        /// The card for one payload, or the reason there can't be one
        public func make(_ payload: Payload) throws -> any Card {
            throw Unimplemented()
        }

        /// Every card that can be made, in order, skipping (and listing) the payloads that can't
        public func feed(from payloads: [Payload]) -> Feed {
            Feed(cards: [], skipped: [])
        }
    }
}
