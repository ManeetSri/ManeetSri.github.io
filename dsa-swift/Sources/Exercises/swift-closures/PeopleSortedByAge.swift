// Problem: Oldest first (M06 · sorted(by:), min, max, contains and first(where:))

public enum PeopleSortedByAge {
    /// A person with a name and an age. `Equatable` lets the tests compare people with `==`.
    public struct Person: Equatable {
        public let name: String
        public let age: Int

        public init(name: String, age: Int) {
            self.name = name
            self.age = age
        }
    }

    /// Returns the people from oldest to youngest. People of the same age are in
    /// alphabetical order of name.
    public static func sorted(_ people: [Person]) -> [Person] {
        // Write your solution here, then run:
        // swift test --filter PeopleSortedByAgeTests
        return []
    }
}
