// Reference solution: Oldest first. sorted(by:) with a two-part rule, O(n log n) time, O(n) space.

public enum PeopleSortedByAge {
    public struct Person: Equatable {
        public let name: String
        public let age: Int

        public init(name: String, age: Int) {
            self.name = name
            self.age = age
        }
    }

    public static func sorted(_ people: [Person]) -> [Person] {
        people.sorted { first, second in
            if first.age != second.age {
                return first.age > second.age     // older first
            }
            return first.name < second.name       // then A to Z
        }
    }
}
