import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PeopleSortedByAgeTests {
    typealias Person = PeopleSortedByAge.Person

    @Test("Puts the oldest first")
    func oldestFirst() {
        let people = [Person(name: "Ben", age: 29), Person(name: "Ada", age: 36), Person(name: "Cleo", age: 41)]
        #expect(PeopleSortedByAge.sorted(people).map(\.name) == ["Cleo", "Ada", "Ben"])
    }

    @Test("Breaks ties alphabetically by name")
    func ties() {
        let people = [
            Person(name: "Dev", age: 30),
            Person(name: "Ada", age: 30),
            Person(name: "Zoe", age: 52),
            Person(name: "Cleo", age: 30),
            Person(name: "Ben", age: 19),
        ]
        let expected = [
            Person(name: "Zoe", age: 52),
            Person(name: "Ada", age: 30),
            Person(name: "Cleo", age: 30),
            Person(name: "Dev", age: 30),
            Person(name: "Ben", age: 19),
        ]
        #expect(PeopleSortedByAge.sorted(people) == expected)
    }

    @Test("Everyone the same age is sorted by name")
    func allSameAge() {
        let people = ["Mia", "Ari", "Leo", "Bea"].map { Person(name: $0, age: 25) }
        #expect(PeopleSortedByAge.sorted(people).map(\.name) == ["Ari", "Bea", "Leo", "Mia"])
    }

    @Test("Empty and single-person lists")
    func tiny() {
        #expect(PeopleSortedByAge.sorted([]) == [])
        let solo = [Person(name: "Ada", age: 36)]
        #expect(PeopleSortedByAge.sorted(solo) == solo)
    }

    @Test("Already sorted and reversed input")
    func orders() {
        let sortedPeople = [Person(name: "A", age: 3), Person(name: "B", age: 2), Person(name: "C", age: 1)]
        #expect(PeopleSortedByAge.sorted(sortedPeople) == sortedPeople)
        #expect(PeopleSortedByAge.sorted(sortedPeople.reversed()) == sortedPeople)
    }

    @Test("Capital letters come before lowercase ones, as with String's <")
    func capitals() {
        let people = [Person(name: "amy", age: 20), Person(name: "Zed", age: 20)]
        #expect(PeopleSortedByAge.sorted(people).map(\.name) == ["Zed", "amy"])
    }

    @Test("Does not change the input")
    func inputUnchanged() {
        let people = [Person(name: "Ben", age: 29), Person(name: "Ada", age: 36)]
        _ = PeopleSortedByAge.sorted(people)
        #expect(people.map(\.name) == ["Ben", "Ada"])
    }
}
