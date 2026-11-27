import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A seeded generator (SplitMix64), so every run makes the same "random" choices
private struct ShuffleRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

@Suite struct PinnedPlaylistShuffleTests {
    /// Shuffles `songs` many times and counts how often each order of the free songs comes out.
    private func orderCounts(_ songs: [String], pinned: Set<Int>, runs: Int, seed: UInt64) -> [String: Int] {
        var random = ShuffleRandom(seed: seed)
        var counts: [String: Int] = [:]
        for _ in 0..<runs {
            let result = PinnedPlaylistShuffle.shuffled(songs, pinned: pinned, using: &random)
            counts[result.joined(separator: ","), default: 0] += 1
        }
        return counts
    }

    @Test("Pinned songs stay put and no song is lost or duplicated", arguments: [
        (["Intro", "Rain", "Neon", "Drift", "Outro"], [0, 4]),
        (["A", "B", "C"], []),
        (["A", "B", "C", "D"], [1, 2]),
        (["A", "A", "B", "B", "C"], [2]),
        (["solo"], []),
    ] as [([String], Set<Int>)])
    func keepsPinnedAndSongs(songs: [String], pinned: Set<Int>) {
        var random = ShuffleRandom(seed: 1)
        for _ in 0..<50 {
            let result = PinnedPlaylistShuffle.shuffled(songs, pinned: pinned, using: &random)
            #expect(result.sorted() == songs.sorted())
            guard result.count == songs.count else { return }
            for index in pinned {
                #expect(result[index] == songs[index])
            }
        }
    }

    @Test("Everything pinned, or nothing to shuffle, returns the playlist unchanged")
    func nothingToShuffle() {
        var random = ShuffleRandom(seed: 2)
        #expect(PinnedPlaylistShuffle.shuffled(["A", "B", "C"], pinned: [0, 1, 2], using: &random) == ["A", "B", "C"])
        #expect(PinnedPlaylistShuffle.shuffled(["A", "B", "C"], pinned: [0, 2], using: &random) == ["A", "B", "C"])
        #expect(PinnedPlaylistShuffle.shuffled([], pinned: [], using: &random) == [])
        #expect(PinnedPlaylistShuffle.shuffled(["only"], pinned: [], using: &random) == ["only"])
    }

    @Test("Every order of three free songs comes out about equally often")
    func uniformThree() {
        let counts = orderCounts(["Intro", "A", "B", "C"], pinned: [0], runs: 60_000, seed: 67)
        #expect(counts.count == 6, "all 3! = 6 orders should appear")
        for (order, count) in counts {
            #expect(abs(count - 10_000) < 500, "order \(order) came out \(count) times; a fair shuffle gives about 10,000")
        }
    }

    @Test("Every order of four free songs around pins comes out about equally often")
    func uniformFourWithPins() {
        let counts = orderCounts(["A", "x", "B", "C", "y", "D"], pinned: [1, 4], runs: 48_000, seed: 2_026)
        #expect(counts.count == 24, "all 4! = 24 orders should appear")
        for (order, count) in counts {
            let parts = order.split(separator: ",", omittingEmptySubsequences: false)
            guard parts.count == 6 else {
                Issue.record("a shuffle returned \(parts.count) songs instead of 6")
                return
            }
            #expect(parts[1] == "x" && parts[4] == "y", "pinned songs moved in \(order)")
            #expect(abs(count - 2_000) < 250, "order \(order) came out \(count) times; a fair shuffle gives about 2,000")
        }
    }

    @Test("The same seed gives the same shuffle, and the generator is really used")
    func reproducible() {
        let songs = (0..<40).map { "song \($0)" }
        var first = ShuffleRandom(seed: 42)
        var second = ShuffleRandom(seed: 42)
        var other = ShuffleRandom(seed: 43)
        let a = PinnedPlaylistShuffle.shuffled(songs, pinned: [0, 39], using: &first)
        let b = PinnedPlaylistShuffle.shuffled(songs, pinned: [0, 39], using: &second)
        let c = PinnedPlaylistShuffle.shuffled(songs, pinned: [0, 39], using: &other)
        #expect(a == b)
        #expect(a != c, "different seeds should give different orders of 38 songs")
        #expect(a != songs, "38 free songs should almost never stay in their original order")
    }

    @Test("100,000 songs with every third one pinned")
    func large() {
        let songs = (0..<100_000).map { "track \($0)" }
        let pinned = Set(stride(from: 0, to: songs.count, by: 3))
        var random = ShuffleRandom(seed: 7)
        let result = PinnedPlaylistShuffle.shuffled(songs, pinned: pinned, using: &random)
        #expect(result.count == songs.count)
        guard result.count == songs.count else { return }
        #expect(pinned.allSatisfy { result[$0] == songs[$0] })
        #expect(Set(result) == Set(songs))
        // In a fair shuffle of 66,666 songs, only about one stays where it was
        let unmoved = songs.indices.filter { !pinned.contains($0) && result[$0] == songs[$0] }.count
        #expect(unmoved < 20)
    }
}
