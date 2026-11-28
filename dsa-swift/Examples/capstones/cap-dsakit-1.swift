// Generated from src/dsa/content/lessons/capstones/cap-dsakit.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// A semantic version: MAJOR.MINOR.PATCH, compared number by number
struct Version: Comparable, CustomStringConvertible {
    let major: Int
    let minor: Int
    let patch: Int

    init(_ major: Int, _ minor: Int, _ patch: Int) {
        (self.major, self.minor, self.patch) = (major, minor, patch)
    }

    /// Parses "1.4.2" or "v1.4.2". Anything else, such as "beta" or "1.4", gives nil.
    init?(_ tag: String) {
        let text = tag.hasPrefix("v") ? tag.dropFirst() : Substring(tag)
        let parts = text.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3, parts.allSatisfy({ !$0.isEmpty && $0.allSatisfy { $0 >= "0" && $0 <= "9" } }) else {
            return nil
        }
        self.init(Int(parts[0])!, Int(parts[1])!, Int(parts[2])!)
    }

    static func < (a: Version, b: Version) -> Bool {
        (a.major, a.minor, a.patch) < (b.major, b.minor, b.patch)
    }

    var description: String { "\(major).\(minor).\(patch)" }
}

/// The three kinds of release, and the version each one leads to
enum Change {
    case fix, addition, breaking

    /// Compares the public API before and after: removing anything breaks callers
    init(oldAPI: Set<String>, newAPI: Set<String>) {
        if !oldAPI.isSubset(of: newAPI) {
            self = .breaking
        } else if newAPI.count > oldAPI.count {
            self = .addition
        } else {
            self = .fix
        }
    }

    func next(after v: Version) -> Version {
        switch self {
        case .breaking: return Version(v.major + 1, 0, 0)
        case .addition: return Version(v.major, v.minor + 1, 0)
        case .fix: return Version(v.major, v.minor, v.patch + 1)
        }
    }
}

/// What SwiftPM's `from:` and `.upToNextMinor(from:)` accept
enum Requirement {
    case upToNextMajor(from: Version)
    case upToNextMinor(from: Version)

    func allows(_ v: Version) -> Bool {
        switch self {
        case .upToNextMajor(let low): return v >= low && v < Version(low.major + 1, 0, 0)
        case .upToNextMinor(let low): return v >= low && v < Version(low.major, low.minor + 1, 0)
        }
    }
}

/// The newest tag the requirement allows, as the package resolver picks it
func resolve(_ requirement: Requirement, tags: [String]) -> Version? {
    tags.compactMap(Version.init).filter(requirement.allows).max()
}

let tags = ["0.9.0", "0.10.0", "1.0.0", "1.2.0", "1.10.0", "1.9.3", "v1.10.1", "2.0.0", "nightly"]
print("as strings: ", tags.sorted().joined(separator: " "))
print("as versions:", tags.compactMap(Version.init).sorted().map(\.description).joined(separator: " "))

print(resolve(.upToNextMajor(from: Version(1, 2, 0)), tags: tags)!)
print(resolve(.upToNextMinor(from: Version(1, 9, 0)), tags: tags)!)
print(resolve(.upToNextMajor(from: Version(0, 9, 0)), tags: tags)!)

let v1: Set = ["Heap.insert", "Heap.pop", "Heap.peek", "Trie.insert"]
let fixed: Set = ["Heap.insert", "Heap.pop", "Heap.peek", "Trie.insert"]
let grown: Set = ["Heap.insert", "Heap.pop", "Heap.peek", "Heap.replaceTop", "Trie.insert"]
let renamed: Set = ["Heap.insert", "Heap.pop", "Heap.top", "Heap.replaceTop", "Trie.insert"]

let current = Version(1, 2, 0)
for (label, api) in [("fixed a bug", fixed), ("added replaceTop", grown), ("renamed peek to top", renamed)] {
    let change = Change(oldAPI: v1, newAPI: api)
    print("\(label): \(change) -> \(change.next(after: current))")
}
print("the rename removed", v1.subtracting(renamed).sorted())
