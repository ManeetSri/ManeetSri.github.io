import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ParentChainDepthsTests {
    // Climbs to the root for each person: fine for small, shallow trees
    static func climbed(_ parents: [Int]) -> [Int] {
        parents.indices.map { start in
            var steps = 0
            var person = start
            while parents[person] != -1 {
                person = parents[person]
                steps += 1
            }
            return steps
        }
    }

    @Test("The examples")
    func examples() {
        #expect(ParentChainDepths.depths([-1, 0, 0, 1, 1, 3]) == [0, 1, 1, 2, 2, 3])
        #expect(ParentChainDepths.depths([2, 2, -1, 0]) == [1, 1, 0, 2])
        #expect(ParentChainDepths.depths([-1]) == [0])
        #expect(ParentChainDepths.depths([1, 2, 3, -1]) == [3, 2, 1, 0])
    }

    @Test("Small shapes")
    func shapes() {
        #expect(ParentChainDepths.depths([-1, 0, 0, 0, 0]) == [0, 1, 1, 1, 1])          // a star
        #expect(ParentChainDepths.depths([1, -1]) == [1, 0])
        #expect(ParentChainDepths.depths([3, 0, 1, -1, 3, 4]) == [1, 2, 3, 0, 1, 2])    // two branches from 3
    }

    @Test("Matches climbing for many small trees")
    func matchesClimbing() {
        var seed = 2_024
        for size in 1...150 {
            // a random tree on a shuffled labelling: each person's parent was added before them
            var order = Array(0..<size)
            for i in stride(from: size - 1, to: 0, by: -1) {
                seed = (seed * 1_103_515_245 + 12_345) % 2_147_483_648
                order.swapAt(i, seed % (i + 1))
            }
            var parents = Array(repeating: -1, count: size)
            for position in 1..<max(size, 1) {
                seed = (seed * 1_103_515_245 + 12_345) % 2_147_483_648
                parents[order[position]] = order[seed % position]
            }
            #expect(ParentChainDepths.depths(parents) == Self.climbed(parents), "parents \(parents)")
        }
    }

    @Test("A chain of 200,000, deepest person first")
    func chainBottomUp() {
        let n = 200_000
        let parents = (0..<n).map { $0 == n - 1 ? -1 : $0 + 1 }
        #expect(ParentChainDepths.depths(parents) == (0..<n).map { n - 1 - $0 })
    }

    @Test("A chain of 200,000, root first")
    func chainTopDown() {
        let n = 200_000
        let parents = (0..<n).map { $0 - 1 }
        #expect(ParentChainDepths.depths(parents) == Array(0..<n))
    }

    @Test("A long spine with leaves hanging off it")
    func caterpillar() {
        // 0 ← 2 ← 4 ← … is a spine; each odd person hangs off the even person before it
        let n = 200_000
        let parents = (0..<n).map { $0 == 0 ? -1 : ($0 % 2 == 0 ? $0 - 2 : $0 - 1) }
        let expected = (0..<n).map { $0 % 2 == 0 ? $0 / 2 : $0 / 2 + 1 }
        #expect(ParentChainDepths.depths(parents) == expected)
    }
}
