// Reference solution: dependency tag resolver. Parse each tag strictly into a (major, minor, patch)
// tuple, which compares number by number, keep the versions every rule allows, and take the largest.
// The next release compares the public API as sets: anything removed is breaking. O(t · L) time for
// t tags of length L, plus O(a) set work for an API of a names.

public enum DependencyTagResolver {
    /// What a package manifest can ask for, written with a version such as "1.2.0".
    public enum Rule: Equatable, Sendable {
        case upToNextMajor(from: String)
        case upToNextMinor(from: String)
        case exact(String)
    }

    private typealias Version = (major: Int, minor: Int, patch: Int)

    public static func resolve(tags: [String], rules: [Rule]) -> String? {
        let bounds = rules.compactMap(range)
        guard bounds.count == rules.count else { return nil }      // a rule with an invalid version
        var best: Version? = nil
        for tag in tags {
            guard let version = parse(tag),
                  bounds.allSatisfy({ !less(version, $0.low) && less(version, $0.end) }) else { continue }
            if best == nil || less(best!, version) { best = version }
        }
        return best.map(text)
    }

    public static func nextRelease(after current: String, oldAPI: Set<String>, newAPI: Set<String>) -> String {
        guard let version = parse(current) else { return current }
        let breaking = !oldAPI.isSubset(of: newAPI)
        let addition = !newAPI.isSubset(of: oldAPI)
        if version.major == 0 {
            // Before 1.0.0, a breaking change bumps the minor number and anything else the patch
            return breaking ? text((0, version.minor + 1, 0)) : text((0, version.minor, version.patch + 1))
        }
        if breaking { return text((version.major + 1, 0, 0)) }
        if addition { return text((version.major, version.minor + 1, 0)) }
        return text((version.major, version.minor, version.patch + 1))
    }

    /// The versions a rule allows, as a half-open range [low, end).
    private static func range(_ rule: Rule) -> (low: Version, end: Version)? {
        switch rule {
        case .upToNextMajor(let from):
            guard let low = parse(from) else { return nil }
            return (low, (low.major + 1, 0, 0))
        case .upToNextMinor(let from):
            guard let low = parse(from) else { return nil }
            return (low, (low.major, low.minor + 1, 0))
        case .exact(let version):
            guard let low = parse(version) else { return nil }
            return (low, (low.major, low.minor, low.patch + 1))
        }
    }

    /// "1.4.2" or "v1.4.2": three numbers without leading zeros, made of ASCII digits only.
    private static func parse(_ tag: String) -> Version? {
        var bytes = Array(tag.utf8)
        if bytes.first == UInt8(ascii: "v") { bytes.removeFirst() }
        let parts = bytes.split(separator: UInt8(ascii: "."), omittingEmptySubsequences: false)
        guard parts.count == 3 else { return nil }
        var numbers: [Int] = []
        for part in parts {
            guard !part.isEmpty,
                  part.allSatisfy({ $0 >= UInt8(ascii: "0") && $0 <= UInt8(ascii: "9") }),
                  part.count == 1 || part.first != UInt8(ascii: "0") else { return nil }
            var value = 0
            for digit in part {
                let (times10, overflow1) = value.multipliedReportingOverflow(by: 10)
                let (next, overflow2) = times10.addingReportingOverflow(Int(digit - UInt8(ascii: "0")))
                guard !overflow1, !overflow2 else { return nil }   // too big for Int: not a version
                value = next
            }
            numbers.append(value)
        }
        return (numbers[0], numbers[1], numbers[2])
    }

    private static func less(_ a: Version, _ b: Version) -> Bool {
        (a.major, a.minor, a.patch) < (b.major, b.minor, b.patch)
    }

    private static func text(_ version: Version) -> String {
        "\(version.major).\(version.minor).\(version.patch)"
    }
}
