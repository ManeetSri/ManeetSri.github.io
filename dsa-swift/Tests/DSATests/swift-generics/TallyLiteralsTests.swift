import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TallyLiteralsTests {
    typealias Tally = TallyLiterals.Tally

    private static func winner(of votes: Tally<String>) -> String {
        votes.mostCommon ?? "nobody"
    }

    @Test("An array literal counts each appearance")
    func arrayLiteral() {
        let tally: Tally = ["tea", "coffee", "tea", "juice", "tea"]
        #expect(tally.count(of: "tea") == 3)
        #expect(tally.count(of: "coffee") == 1)
        #expect(tally.count(of: "water") == 0)
        #expect(tally.total == 5)
        #expect(tally.distinctCount == 3)
        #expect(tally.elements == ["tea", "coffee", "juice"])
    }

    @Test("A dictionary literal gives counts directly")
    func dictionaryLiteral() {
        let tally: Tally = ["red": 3, "blue": 1, "green": 0, "grey": -2]
        #expect(tally.count(of: "red") == 3)
        #expect(tally.count(of: "blue") == 1)
        #expect(tally.count(of: "green") == 0)
        #expect(tally.count(of: "grey") == 0)
        #expect(tally.total == 4)
        #expect(tally.elements == ["red", "blue"])
    }

    @Test("A repeated key in a dictionary literal adds up")
    func repeatedKey() {
        let tally: Tally<Int> = [7: 2, 3: 1, 7: 5]
        #expect(tally.count(of: 7) == 7)
        #expect(tally.elements == [7, 3])
        #expect(tally.mostCommon == 7)
    }

    @Test("Empty literals and init() make an empty tally")
    func empty() {
        let fromArray: Tally<String> = []
        let fromDictionary: Tally<String> = [:]
        for tally in [fromArray, fromDictionary, Tally<String>()] {
            #expect(tally.total == 0)
            #expect(tally.distinctCount == 0)
            #expect(tally.mostCommon == nil)
            #expect(tally.elements == [])
        }
    }

    @Test("add counts up, and ignores zero or negative times")
    func add() {
        var tally = Tally<Character>()
        tally.add("a")
        tally.add("b", times: 4)
        tally.add("a", times: 2)
        tally.add("c", times: 0)
        tally.add("d", times: -1)
        #expect(tally.count(of: "a") == 3)
        #expect(tally.count(of: "b") == 4)
        #expect(tally.count(of: "c") == 0)
        #expect(tally.total == 7)
        #expect(tally.elements == ["a", "b"])
        #expect(tally.mostCommon == "b")
    }

    @Test("mostCommon breaks ties by first arrival")
    func ties() {
        let tally: Tally = ["b", "a", "a", "b", "c"]
        #expect(tally.mostCommon == "b")
        let numbers: Tally = [3, 1, 2]
        #expect(numbers.mostCommon == 3)
    }

    @Test("Literals work as arguments")
    func literalArguments() {
        #expect(Self.winner(of: ["yes", "no", "no"]) == "no")
        #expect(Self.winner(of: ["yes": 4, "no": 3]) == "yes")
        #expect(Self.winner(of: []) == "nobody")
    }

    @Test("merged adds two tallies, keeping first-arrival order")
    func merged() {
        let first: Tally = ["a", "b"]
        let combined = first.merged(with: ["c": 1, "b": 2])
        #expect(combined.count(of: "a") == 1)
        #expect(combined.count(of: "b") == 3)
        #expect(combined.count(of: "c") == 1)
        #expect(combined.elements == ["a", "b", "c"])
        #expect(combined.mostCommon == "b")
        #expect(first.count(of: "b") == 1, "merged returns a new tally and leaves the original alone")
    }

    @Test("A large tally")
    func large() {
        var tally = Tally<Int>()
        for value in 0..<100_000 {
            tally.add(value % 7)
        }
        #expect(tally.total == 100_000)
        #expect(tally.distinctCount == 7)
        #expect(tally.count(of: 0) == 14_286)
        #expect(tally.count(of: 6) == 14_285)
        #expect(tally.mostCommon == 0)
    }
}
