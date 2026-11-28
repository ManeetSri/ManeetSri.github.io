// Reference solution: Ordering versions. Comparing and describing are O(1); parsing is O(n) in the
// length of the text.

public enum VersionOrdering {
    public struct Version: Comparable, CustomStringConvertible {
        public let major: Int
        public let minor: Int
        public let patch: Int

        public init(major: Int, minor: Int, patch: Int) {
            self.major = major
            self.minor = minor
            self.patch = patch
        }

        // omittingEmptySubsequences: false keeps empty parts, so "1..2.3" and "1.2.3." are rejected
        // instead of being quietly read as "1.2.3"
        public init?(_ text: String) {
            let parts = text.split(separator: ".", omittingEmptySubsequences: false)
            guard parts.count == 3 else { return nil }
            var numbers: [Int] = []
            for part in parts {
                guard !part.isEmpty, part.allSatisfy({ $0.isASCII && $0.isNumber }), let number = Int(part) else {
                    return nil
                }
                numbers.append(number)
            }
            self.init(major: numbers[0], minor: numbers[1], patch: numbers[2])
        }

        // Tuples compare element by element: major first, then minor, then patch
        public static func < (lhs: Version, rhs: Version) -> Bool {
            (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch)
        }

        public var description: String {
            "\(major).\(minor).\(patch)"
        }
    }
}
