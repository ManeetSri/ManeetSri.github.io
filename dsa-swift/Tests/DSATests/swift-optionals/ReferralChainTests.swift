import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ReferralChainTests {
    // Ana referred Ben, Ben referred Cleo, Cleo referred Dev and Eve. Ana wasn't referred by anyone.
    let referredBy = [
        "Ben": "Ana",
        "Cleo": "Ben",
        "Dev": "Cleo",
        "Eve": "Cleo",
    ]

    @Test("Follows the chain", arguments: [
        ("Dev", 1, "Cleo"),
        ("Dev", 2, "Ben"),
        ("Dev", 3, "Ana"),
        ("Eve", 2, "Ben"),
        ("Ben", 1, "Ana"),
    ])
    func follows(person: String, steps: Int, expected: String) {
        #expect(ReferralChain.ancestor(of: person, steps: steps, in: referredBy) == expected)
    }

    @Test("Zero steps gives the person themselves", arguments: ["Dev", "Ana", "Zoe"])
    func zeroSteps(person: String) {
        #expect(ReferralChain.ancestor(of: person, steps: 0, in: referredBy) == person)
    }

    @Test("Returns nil when the chain ends too soon", arguments: [
        ("Dev", 4),
        ("Ana", 1),
        ("Ben", 2),
        ("Cleo", 10),
    ])
    func tooFar(person: String, steps: Int) {
        #expect(ReferralChain.ancestor(of: person, steps: steps, in: referredBy) == nil)
    }

    @Test("Returns nil for someone not in the network")
    func stranger() {
        #expect(ReferralChain.ancestor(of: "Zoe", steps: 1, in: referredBy) == nil)
        #expect(ReferralChain.ancestor(of: "Dev", steps: 1, in: [:]) == nil)
    }

    @Test("Follows a long chain")
    func longChain() {
        var chain: [String: String] = [:]
        for i in 1...1_000 {
            chain["p\(i)"] = "p\(i - 1)"
        }
        #expect(ReferralChain.ancestor(of: "p1000", steps: 1_000, in: chain) == "p0")
        #expect(ReferralChain.ancestor(of: "p1000", steps: 250, in: chain) == "p750")
        #expect(ReferralChain.ancestor(of: "p1000", steps: 1_001, in: chain) == nil)
    }
}
