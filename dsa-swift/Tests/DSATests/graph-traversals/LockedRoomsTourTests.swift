import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LockedRoomsTourTests {
    @Test("Every room can be opened", arguments: [
        [[1], [2], [3], []],
        [[1, 2], [], []],
        [[2], [], [1]],
        [[]],
        [[1, 1, 0], [0, 2], [2, 1]],
        [[3], [0], [1], [2]],
    ])
    func allOpen(keys: [[Int]]) {
        #expect(LockedRoomsTour.canOpenAll(keys))
    }

    @Test("Some room stays locked", arguments: [
        [[1, 3], [3, 0, 1], [2], [0]],
        [[], [0]],
        [[0, 0], [1]],
        [[1], [0], [3], [2]],
        [[1], [], [1, 0]],
    ])
    func someLocked(keys: [[Int]]) {
        #expect(!LockedRoomsTour.canOpenAll(keys))
    }

    @Test("A chain of 100,000 rooms, each holding the next key")
    func longChain() {
        // A recursive search would go 100,000 calls deep, far past a test thread's stack
        let count = 100_000
        var keys = (0..<count).map { [$0 + 1] }
        keys[count - 1] = []
        let wholeChain = LockedRoomsTour.canOpenAll(keys)
        #expect(wholeChain, "every room in the chain can be opened")

        keys[60_000] = []                                // the chain breaks here
        let brokenChain = LockedRoomsTour.canOpenAll(keys)
        #expect(!brokenChain, "rooms after 60,000 stay locked")
    }

    @Test("A backwards chain and a star of 100,000 rooms")
    func backwardsAndStar() {
        let count = 100_000
        // 0 → 99,999 → 99,998 → … → 1
        var backwards = (0..<count).map { [$0 - 1] }
        backwards[0] = [count - 1]
        backwards[1] = [0]
        let backwardsOpen = LockedRoomsTour.canOpenAll(backwards)
        #expect(backwardsOpen, "the backwards chain opens every room")

        var star = Array(repeating: [Int](), count: count)
        star[0] = Array(1..<count)
        let starOpen = LockedRoomsTour.canOpenAll(star)
        #expect(starOpen, "room 0 holds every key")

        // Every room holds the keys to rooms 0 to 9 only
        let crowded = Array(repeating: Array(0..<10), count: count)
        let crowdedOpen = LockedRoomsTour.canOpenAll(crowded)
        #expect(!crowdedOpen, "only rooms 0 to 9 can be opened")
    }
}
