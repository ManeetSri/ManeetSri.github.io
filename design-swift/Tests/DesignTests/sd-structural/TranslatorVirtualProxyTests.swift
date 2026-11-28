import DesignKit
import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TranslatorVirtualProxyTests {
    typealias Proxy = TranslatorVirtualProxy.LazyTranslator

    /// A stand-in for the real model: it "translates" by shouting
    struct ShoutingModel: TranslatorVirtualProxy.Translating {
        func translate(_ text: String) async throws -> String { text.uppercased() }
    }

    /// A model that loads, but can't translate anything
    struct BrokenModel: TranslatorVirtualProxy.Translating {
        func translate(_ text: String) async throws -> String { throw ModelError.unsupportedLanguage }
    }

    enum LoadError: Error { case outOfSpace }
    enum ModelError: Error { case unsupportedLanguage }

    /// Yields until `condition` holds, or gives up after a while so a broken solution can't hang the run
    private func waitUntil(_ condition: () -> Bool) async {
        var rounds = 0
        while !condition() && rounds < 10_000 {
            await Task.yield()
            rounds += 1
        }
    }

    @Test("Loads the model on first use, not before")
    func loadsOnFirstUse() async throws {
        let loads = Recorder<Int>()
        let proxy = Proxy { await loads.record(1); return ShoutingModel() }
        await settle()
        #expect(await loads.values.isEmpty)
        #expect(await proxy.isLoaded == false)
        #expect(try await proxy.translate("hello") == "HELLO")
        #expect(await loads.values.count == 1)
        #expect(await proxy.isLoaded)
    }

    @Test("Later calls reuse the loaded model")
    func reusesTheModel() async throws {
        let loads = Recorder<Int>()
        let proxy = Proxy { await loads.record(1); return ShoutingModel() }
        var translations: [String] = []
        for word in ["one", "two", "three"] {
            translations.append(try await proxy.translate(word))
        }
        #expect(translations == ["ONE", "TWO", "THREE"])
        #expect(await loads.values.count == 1)
    }

    @Test("Callers that arrive during a load share it")
    func sharesOneLoad() async throws {
        let clock = TestClock()
        let loads = Recorder<Int>()
        let proxy = Proxy {
            await loads.record(1)
            try await clock.sleep(for: .seconds(2))
            return ShoutingModel()
        }
        async let first = proxy.translate("a")
        async let second = proxy.translate("b")
        async let third = proxy.translate("c")
        await waitUntil { clock.sleeperCount > 0 }
        await settle()
        #expect(clock.sleeperCount == 1)
        #expect(await proxy.isLoaded == false)
        clock.advance(by: .seconds(2))
        #expect(try await [first, second, third] == ["A", "B", "C"])
        #expect(await loads.values.count == 1)
        #expect(await proxy.isLoaded)
    }

    @Test("A failed load reaches every waiting caller, and the next call tries again")
    func retriesAfterFailure() async throws {
        let clock = TestClock()
        let loads = Recorder<Int>()
        let proxy = Proxy {
            await loads.record(1)
            try await clock.sleep(for: .seconds(1))
            if await loads.values.count == 1 { throw LoadError.outOfSpace }
            return ShoutingModel()
        }
        async let first = proxy.translate("a")
        async let second = proxy.translate("b")
        await waitUntil { clock.sleeperCount > 0 }
        await settle()
        clock.advance(by: .seconds(1))
        do {
            _ = try await first
            Issue.record("The first caller should get the load's error")
        } catch {
            #expect(error as? LoadError == .outOfSpace)
        }
        do {
            _ = try await second
            Issue.record("The second caller should get the same error")
        } catch {
            #expect(error as? LoadError == .outOfSpace)
        }
        #expect(await proxy.isLoaded == false)

        async let retry = proxy.translate("c")
        await waitUntil { clock.sleeperCount > 0 }
        clock.advance(by: .seconds(1))
        #expect(try await retry == "C")
        #expect(await loads.values.count == 2)
    }

    @Test("Unloading frees the model, and the next call loads it again")
    func unloads() async throws {
        let loads = Recorder<Int>()
        let proxy = Proxy { await loads.record(1); return ShoutingModel() }
        #expect(try await proxy.translate("before") == "BEFORE")
        await proxy.unload()
        #expect(await proxy.isLoaded == false)
        #expect(try await proxy.translate("after") == "AFTER")
        #expect(await loads.values.count == 2)
    }

    @Test("An error from the model itself is passed on, and the model stays loaded")
    func modelErrors() async throws {
        let loads = Recorder<Int>()
        let proxy = Proxy { await loads.record(1); return BrokenModel() }
        await #expect(throws: ModelError.unsupportedLanguage) { try await proxy.translate("a") }
        await #expect(throws: ModelError.unsupportedLanguage) { try await proxy.translate("b") }
        #expect(await proxy.isLoaded)
        #expect(await loads.values.count == 1)
    }
}
