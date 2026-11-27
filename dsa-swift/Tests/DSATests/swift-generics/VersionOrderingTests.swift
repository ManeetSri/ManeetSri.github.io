import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct VersionOrderingTests {
    typealias Version = VersionOrdering.Version

    @Test("Parses valid versions", arguments: [
        ("1.2.3", 1, 2, 3),
        ("0.0.0", 0, 0, 0),
        ("10.20.30", 10, 20, 30),
        ("1.10.2", 1, 10, 2),
        ("01.002.3", 1, 2, 3),
        ("123456789.0.987654321", 123_456_789, 0, 987_654_321),
    ])
    func parses(text: String, major: Int, minor: Int, patch: Int) {
        let version = Version(text)
        #expect(version == Version(major: major, minor: minor, patch: patch))
    }

    @Test("Rejects anything that isn't three runs of digits", arguments: [
        "", "1", "1.2", "1.2.3.4", "1..2.3", ".1.2.3", "1.2.3.", "1.2.", ".1.2", "...", "1.x.3", "1.-2.3", "+1.2.3",
    ])
    func rejects(text: String) {
        #expect(Version(text) == nil)
    }

    @Test("Compares parts as numbers, not as text")
    func numericComparison() {
        #expect(Version(major: 1, minor: 2, patch: 0) < Version(major: 1, minor: 10, patch: 0))
        #expect(Version(major: 1, minor: 99, patch: 99) < Version(major: 2, minor: 0, patch: 0))
        #expect(Version(major: 3, minor: 1, patch: 4) < Version(major: 3, minor: 1, patch: 5))
        #expect(Version(major: 2, minor: 0, patch: 0) > Version(major: 1, minor: 50, patch: 50))
    }

    @Test("< is strict")
    func strict() {
        let version = Version(major: 1, minor: 2, patch: 3)
        #expect(!(version < version))
        #expect(version <= version)
        #expect(version >= version)
    }

    @Test("Sorts, and finds the newest and oldest")
    func sorting() {
        let texts = ["1.10.0", "1.2.3", "2.0.0", "0.9.9", "1.2.10"]
        let versions = texts.compactMap { Version($0) }
        #expect(versions.count == 5)
        #expect(versions.sorted().map(\.description) == ["0.9.9", "1.2.3", "1.2.10", "1.10.0", "2.0.0"])
        #expect(versions.max()?.description == "2.0.0")
        #expect(versions.min()?.description == "0.9.9")
    }

    @Test("Describes itself as major.minor.patch")
    func description() {
        let version = Version(major: 1, minor: 10, patch: 2)
        #expect(version.description == "1.10.2")
        #expect("v\(version)" == "v1.10.2")
        #expect(Version("01.02.03")?.description == "1.2.3")
    }
}
