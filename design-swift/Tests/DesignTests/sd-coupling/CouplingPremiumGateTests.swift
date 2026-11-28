import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Gate = CouplingPremiumGate.Gate
private typealias Feature = CouplingPremiumGate.Feature

/// A stand-in for whatever knows the user's purchases: answers from a script and counts the questions
private actor ScriptedEntitlements: CouplingPremiumGate.EntitlementSource {
    private var answers: [Result<Set<String>, any Error>]
    private(set) var calls = 0

    /// Each call takes the next answer; the last one repeats
    init(_ answers: [Result<Set<String>, any Error>]) {
        self.answers = answers
    }

    func activeEntitlements() async throws -> Set<String> {
        calls += 1
        let answer = answers.count > 1 ? answers.removeFirst() : answers[0]
        return try answer.get()
    }
}

private struct Offline: Error {}

private let stickers = Feature(name: "Stickers", entitlement: nil)
private let themes = Feature(name: "Themes", entitlement: "pro")
private let sharing = Feature(name: "Family sharing", entitlement: "family")

@Suite struct CouplingPremiumGateTests {
    @Test("Free features are granted without asking the source")
    func freeFeatures() async {
        let source = ScriptedEntitlements([.failure(Offline())])
        let gate = Gate(source: source)
        #expect(await gate.access(to: stickers) == .granted)
        #expect(await source.calls == 0)
    }

    @Test("An active entitlement unlocks its own feature, and only that one")
    func activeEntitlement() async {
        let gate = Gate(source: ScriptedEntitlements([.success(["pro"])]))
        #expect(await gate.access(to: themes) == .granted)
        #expect(await gate.access(to: sharing) == .locked)
    }

    @Test("With no purchases, paid features are locked")
    func noPurchases() async {
        let gate = Gate(source: ScriptedEntitlements([.success([])]))
        #expect(await gate.access(to: themes) == .locked)
        #expect(await gate.access(to: stickers) == .granted)
    }

    @Test("A failed check with nothing remembered is unknown, never a paywall")
    func unknownWhenNeverChecked() async {
        let gate = Gate(source: ScriptedEntitlements([.failure(Offline())]))
        #expect(await gate.access(to: themes) == .unknown)
    }

    @Test("A subscriber who goes offline keeps access from the last answer")
    func offlineUsesLastAnswer() async {
        let source = ScriptedEntitlements([.success(["pro"]), .failure(Offline())])
        let gate = Gate(source: source)
        #expect(await gate.access(to: themes) == .granted)
        #expect(await gate.access(to: themes) == .granted)
        #expect(await gate.access(to: sharing) == .locked)
        #expect(await source.calls == 3)
    }

    @Test("A lapsed subscription locks the feature at the next successful check")
    func lapsedSubscription() async {
        let gate = Gate(source: ScriptedEntitlements([.success(["pro"]), .success([])]))
        #expect(await gate.access(to: themes) == .granted)
        #expect(await gate.access(to: themes) == .locked)
    }

    @Test("The adapter reports only the entitlements the vendor marks active")
    func adapterMapsActive() async throws {
        let info = CouplingPremiumGate.VendorCustomerInfo(entitlements: [
            "pro": .init(identifier: "pro", isActive: true),
            "family": .init(identifier: "family", isActive: false),
            "legacy": .init(identifier: "legacy", isActive: true),
        ])
        let adapter = CouplingPremiumGate.VendorEntitlementSource(purchases: .init(answering: .success(info)))
        #expect(try await adapter.activeEntitlements() == ["pro", "legacy"])
    }

    @Test("The adapter passes the vendor's error on")
    func adapterPassesErrors() async {
        let adapter = CouplingPremiumGate.VendorEntitlementSource(purchases: .init(answering: .failure(.notConfigured)))
        await #expect(throws: CouplingPremiumGate.VendorError.notConfigured) {
            try await adapter.activeEntitlements()
        }
    }

    @Test("The gate works through the adapter without knowing the vendor exists")
    func endToEnd() async {
        let info = CouplingPremiumGate.VendorCustomerInfo(entitlements: ["pro": .init(identifier: "pro", isActive: true)])
        let source = CouplingPremiumGate.VendorEntitlementSource(purchases: .init(answering: .success(info)))
        let gate = Gate(source: source)
        #expect(await gate.access(to: themes) == .granted)
        #expect(await gate.access(to: sharing) == .locked)
    }
}
