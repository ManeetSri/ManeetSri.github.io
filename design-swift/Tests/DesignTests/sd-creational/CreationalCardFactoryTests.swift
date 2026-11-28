import DesignKit
import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Cards = CreationalCardFactory

/// A card type the factory has never heard of, registered by the "app" in these tests
private struct Poll: CreationalCardFactory.Card, Equatable {
    let id: String
    let question: String
}

@Suite struct CreationalCardFactoryTests {
    @Test("The standard factory makes articles and promos")
    func standardTypes() throws {
        let factory = Cards.Factory.standard()

        let article = try factory.make(.init(type: "article", id: "a1", fields: ["title": "Factories", "url": "https://example.com/f"]))
        #expect(article as? Cards.Article == Cards.Article(id: "a1", title: "Factories", url: URL(string: "https://example.com/f")!))

        let promo = try factory.make(.init(type: "promo", id: "p1", fields: ["headline": "Spring sale", "code": "spring25"]))
        #expect(promo as? Cards.Promo == Cards.Promo(id: "p1", headline: "Spring sale", code: "SPRING25"))
    }

    @Test("A payload that can't be a card says why", arguments: [
        (Cards.Payload(type: "article", id: "a", fields: ["url": "https://example.com"]), Cards.MakeError.missingField("title")),
        (Cards.Payload(type: "article", id: "a", fields: ["title": "", "url": "https://example.com"]), .missingField("title")),
        (Cards.Payload(type: "article", id: "a"), .missingField("title")),
        (Cards.Payload(type: "article", id: "a", fields: ["title": "T"]), .missingField("url")),
        (Cards.Payload(type: "article", id: "a", fields: ["title": "T", "url": "http://example.com"]), .invalidField("url")),
        (Cards.Payload(type: "article", id: "a", fields: ["title": "T", "url": "not a link"]), .invalidField("url")),
        (Cards.Payload(type: "promo", id: "p", fields: ["code": "X"]), .missingField("headline")),
        (Cards.Payload(type: "promo", id: "p", fields: ["headline": "H"]), .missingField("code")),
        (Cards.Payload(type: "poll", id: "q"), .unknownType("poll")),
        (Cards.Payload(type: "Article", id: "a", fields: ["title": "T", "url": "https://example.com"]), .unknownType("Article")),
    ])
    func rejects(payload: CreationalCardFactory.Payload, error: CreationalCardFactory.MakeError) {
        #expect(throws: error) {
            try Cards.Factory.standard().make(payload)
        }
    }

    @Test("A feed keeps the cards in order and lists what it skipped")
    func feedSkips() {
        let feed = Cards.Factory.standard().feed(from: [
            .init(type: "article", id: "a1", fields: ["title": "One", "url": "https://example.com/1"]),
            .init(type: "poll", id: "q1", fields: ["question": "Tabs?"]),
            .init(type: "promo", id: "p1", fields: ["headline": "Sale", "code": "save10"]),
            .init(type: "article", id: "a2", fields: ["title": "Broken"]),
            .init(type: "article", id: "a3", fields: ["title": "Three", "url": "https://example.com/3"]),
        ])
        #expect(feed.cards.map(\.id) == ["a1", "p1", "a3"])
        #expect(feed.skipped == ["q1", "a2"])
    }

    @Test("New card types can be registered without changing the factory")
    func registersNewType() throws {
        var factory = Cards.Factory.standard()
        factory.register("poll") { payload in
            guard let question = payload.fields["question"] else { throw Cards.MakeError.missingField("question") }
            return Poll(id: payload.id, question: question)
        }

        let card = try factory.make(.init(type: "poll", id: "q1", fields: ["question": "Tabs or spaces?"]))
        #expect(card as? Poll == Poll(id: "q1", question: "Tabs or spaces?"))

        let feed = factory.feed(from: [
            .init(type: "poll", id: "q2"),
            .init(type: "article", id: "a1", fields: ["title": "Still works", "url": "https://example.com/a"]),
        ])
        #expect(feed.cards.map(\.id) == ["a1"])
        #expect(feed.skipped == ["q2"])
    }

    @Test("Registering a type again replaces its maker")
    func replacesMaker() throws {
        var factory = Cards.Factory.standard()
        factory.register("promo") { payload in
            Cards.Promo(id: payload.id, headline: payload.fields["headline"] ?? "Staff offer", code: "STAFF")
        }
        let card = try factory.make(.init(type: "promo", id: "p1"))
        #expect(card as? Cards.Promo == Cards.Promo(id: "p1", headline: "Staff offer", code: "STAFF"))
    }

    @Test("A new factory knows no types until they're registered")
    func emptyFactory() {
        #expect(throws: Cards.MakeError.unknownType("article")) {
            try Cards.Factory().make(.init(type: "article", id: "a1", fields: ["title": "T", "url": "https://example.com"]))
        }
        let feed = Cards.Factory().feed(from: [.init(type: "article", id: "a1"), .init(type: "promo", id: "p1")])
        #expect(feed.cards.isEmpty)
        #expect(feed.skipped == ["a1", "p1"])
    }

    @Test("A factory is a value: extending a copy leaves the original alone")
    func valueSemantics() throws {
        let standard = Cards.Factory.standard()
        var extended = standard
        extended.register("poll") { Poll(id: $0.id, question: $0.fields["question"] ?? "") }

        #expect(try extended.make(.init(type: "poll", id: "q1")) is Poll)
        #expect(throws: Cards.MakeError.unknownType("poll")) {
            try standard.make(.init(type: "poll", id: "q1"))
        }
    }
}
