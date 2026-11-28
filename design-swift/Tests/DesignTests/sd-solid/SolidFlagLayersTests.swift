import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SolidFlagLayersTests {
    typealias FixedValues = SolidFlagLayers.FixedValues
    typealias LocalOverrides = SolidFlagLayers.LocalOverrides
    typealias Layer = SolidFlagLayers.Layer

    private let bundled = FixedValues(["checkout.newFlow": "off", "feed.pageSize": "20", "search.enabled": "on"])
    private let remote = FixedValues(["checkout.newFlow": "on", "feed.pageSize": "50"])

    private func layered() -> SolidFlagLayers.LayeredSettings<LocalOverrides> {
        SolidFlagLayers.LayeredSettings(overrides: LocalOverrides(), fallbacks: [remote, bundled])
    }

    /// The SettingsWriter contract, written once and run against every conforming type. `key` may have a
    /// value in a layer underneath, but the writer itself hasn't set it; `other` is a key the test never sets.
    private func checkContract<Writer: SolidFlagLayers.SettingsWriter>(_ writer: Writer, key: String, other: String = "contract.untouched", sourceLocation: SourceLocation = #_sourceLocation) {
        var writer = writer
        let original = writer.value(for: key)
        let otherOriginal = writer.value(for: other)
        writer.set("first", for: key)
        #expect(writer.value(for: key) == "first", "a value you set reads back", sourceLocation: sourceLocation)
        writer.set("second", for: key)
        #expect(writer.value(for: key) == "second", "the latest value wins", sourceLocation: sourceLocation)
        #expect(writer.value(for: other) == otherOriginal, "other keys don't change", sourceLocation: sourceLocation)
        writer.set(nil, for: key)
        #expect(writer.value(for: key) == original, "removing goes back to what was there before", sourceLocation: sourceLocation)
    }

    @Test("Fixed values answer only for the keys they hold")
    func fixedValues() {
        #expect(bundled.value(for: "feed.pageSize") == "20")
        #expect(remote.value(for: "checkout.newFlow") == "on")
        #expect(remote.value(for: "search.enabled") == nil)
    }

    @Test("Local overrides keep the writer contract")
    func overridesContract() {
        checkContract(LocalOverrides(), key: "debug.verboseLogging")
        checkContract(LocalOverrides(["debug.slowAnimations": "on"]), key: "debug.verboseLogging", other: "debug.slowAnimations")
        var preset = LocalOverrides(["a": "1"])
        #expect(preset.value(for: "a") == "1")
        preset.set(nil, for: "a")
        #expect(preset.value(for: "a") == nil)
    }

    @Test("Layered settings keep the same contract, so they can stand in for any writer")
    func layeredContract() {
        checkContract(layered(), key: "debug.verboseLogging")
        checkContract(layered(), key: "checkout.newFlow")
        checkContract(layered(), key: "search.enabled")
        let nested = SolidFlagLayers.LayeredSettings(overrides: layered(), fallbacks: [FixedValues(["x": "1"])])
        checkContract(nested, key: "x")
        #expect(nested.value(for: "x") == "1")
    }

    @Test("Reads come from the first layer that has the key")
    func readOrder() {
        let settings = layered()
        #expect(settings.value(for: "checkout.newFlow") == "on")
        #expect(settings.layer(for: "checkout.newFlow") == .fallback(0))
        #expect(settings.value(for: "search.enabled") == "on")
        #expect(settings.layer(for: "search.enabled") == .fallback(1))
        #expect(settings.value(for: "missing") == nil)
        #expect(settings.layer(for: "missing") == nil)
    }

    @Test("Writes go to the overrides, and removing one reveals the layer underneath")
    func writes() {
        var settings = layered()
        settings.set("off", for: "checkout.newFlow")
        #expect(settings.value(for: "checkout.newFlow") == "off")
        #expect(settings.layer(for: "checkout.newFlow") == .overrides)
        #expect(settings.overrides.value(for: "checkout.newFlow") == "off")
        #expect(remote.value(for: "checkout.newFlow") == "on")
        settings.set(nil, for: "checkout.newFlow")
        #expect(settings.value(for: "checkout.newFlow") == "on")
        #expect(settings.layer(for: "checkout.newFlow") == .fallback(0))
    }

    @Test("One toggle, written against the contract, works on every writer")
    func toggle() {
        var overrides = LocalOverrides(["maybe": "perhaps"])
        SolidFlagLayers.toggle("new", in: &overrides)
        #expect(overrides.value(for: "new") == "on")
        SolidFlagLayers.toggle("new", in: &overrides)
        #expect(overrides.value(for: "new") == "off")
        SolidFlagLayers.toggle("maybe", in: &overrides)
        #expect(overrides.value(for: "maybe") == "on")

        var settings = layered()
        SolidFlagLayers.toggle("checkout.newFlow", in: &settings)
        #expect(settings.value(for: "checkout.newFlow") == "off")
        #expect(settings.layer(for: "checkout.newFlow") == .overrides)
        SolidFlagLayers.toggle("checkout.newFlow", in: &settings)
        #expect(settings.value(for: "checkout.newFlow") == "on")
    }
}
