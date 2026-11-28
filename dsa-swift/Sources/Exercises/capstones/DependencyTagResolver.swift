// Problem: Dependency tag resolver (M74 · Publish DSAKit, your own tested package)

public enum DependencyTagResolver {
    /// What a package manifest can ask for, written with a version such as "1.2.0".
    public enum Rule: Equatable, Sendable {
        case upToNextMajor(from: String)
        case upToNextMinor(from: String)
        case exact(String)
    }

    /// The newest valid tag that every rule allows, written as "major.minor.patch", or nil if none.
    public static func resolve(tags: [String], rules: [Rule]) -> String? {
        // Write your solution here, then run:
        // swift test --filter DependencyTagResolverTests
        return nil
    }

    /// The version to release after `current`, judged by comparing the old and new public API.
    public static func nextRelease(after current: String, oldAPI: Set<String>, newAPI: Set<String>) -> String {
        return current
    }
}
