// Problem: Ordering versions (M10 · Equatable, Comparable and CustomStringConvertible)

public enum VersionOrdering {
    /// A version number such as 1.10.2: major, minor and patch.
    public struct Version: Comparable, CustomStringConvertible {
        public let major: Int
        public let minor: Int
        public let patch: Int

        public init(major: Int, minor: Int, patch: Int) {
            self.major = major
            self.minor = minor
            self.patch = patch
        }

        // Write your solution here, then run:
        // swift test --filter VersionOrderingTests

        /// Reads text like "1.10.2": exactly three non-empty runs of digits separated by dots.
        /// Returns nil for anything else.
        public init?(_ text: String) {
            return nil
        }

        /// Orders by major, then minor, then patch, comparing them as numbers.
        public static func < (lhs: Version, rhs: Version) -> Bool {
            return false
        }

        /// The version written as "major.minor.patch", for example "1.10.2".
        public var description: String {
            return ""
        }
    }
}
