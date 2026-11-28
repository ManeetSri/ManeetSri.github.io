import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TrustedArchivistTests {
    @Test("Small villages", arguments: [
        (3, [[0, 2], [1, 2]], 2),
        (3, [[0, 2], [1, 2], [2, 0]], -1),           // the candidate trusts someone
        (4, [[0, 3], [1, 3], [2, 3], [0, 1]], 3),    // other trusts don't matter
        (4, [[0, 3], [1, 3]], -1),                   // 2 doesn't trust 3
        (3, [[0, 1], [1, 2], [2, 0]], -1),           // a ring: nobody qualifies
        (2, [[0, 1]], 1),
        (2, [[1, 0]], 0),
        (2, [[0, 1], [1, 0]], -1),
        (5, [[4, 0], [3, 0], [2, 0], [1, 0], [4, 1], [3, 1], [2, 1]], 0),
    ])
    func small(peopleCount: Int, trusts: [[Int]], expected: Int) {
        #expect(TrustedArchivist.find(peopleCount: peopleCount, trusts: trusts) == expected)
    }

    @Test("Nobody trusts anybody")
    func noTrust() {
        #expect(TrustedArchivist.find(peopleCount: 1, trusts: []) == 0)   // trusted by all 0 others
        #expect(TrustedArchivist.find(peopleCount: 2, trusts: []) == -1)
        #expect(TrustedArchivist.find(peopleCount: 5, trusts: []) == -1)
    }

    @Test("Trusted by everyone but not quite")
    func almost() {
        // 0 is trusted by 1, 2 and 3 but not by 4; 4 is trusted by nobody
        #expect(TrustedArchivist.find(peopleCount: 5, trusts: [[1, 0], [2, 0], [3, 0], [0, 4]]) == -1)
        // 1 and 2 are each trusted by both others, but each of them trusts someone
        #expect(TrustedArchivist.find(peopleCount: 3, trusts: [[0, 2], [1, 2], [2, 1], [0, 1]]) == -1)
        // 1 is trusted by everyone else and trusts nobody, although 1's index is not the last
        #expect(TrustedArchivist.find(peopleCount: 4, trusts: [[0, 1], [2, 1], [3, 1], [3, 2], [0, 2]]) == 1)
    }

    @Test("100,000 people")
    func large() {
        let count = 100_000
        let archivist = 77_777
        var trusts: [[Int]] = []
        for person in 0..<count where person != archivist {
            trusts.append([person, archivist])
            let friend = (person + 1) % count
            if friend != archivist {
                trusts.append([person, friend])
            }
        }
        #expect(TrustedArchivist.find(peopleCount: count, trusts: trusts) == archivist)
        trusts.append([archivist, 5])
        #expect(TrustedArchivist.find(peopleCount: count, trusts: trusts) == -1)
    }
}
