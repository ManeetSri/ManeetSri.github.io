import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PrinciplesPlaybackQueueTests {
    typealias Queue = PrinciplesPlaybackQueue

    let album = ["Intro", "Ocean", "Lights", "Outro"]

    /// Taps skip `count` times, returning whether each tap skipped
    private func skip(_ count: Int, on player: inout Queue.Player) -> [Bool] {
        (0..<count).map { _ in player.skip() }
    }

    /// Lets the queue play on its own, recording each track as it starts, until it ends or `limit` tracks
    private func playThrough(_ player: inout Queue.Player, limit: Int = 20) -> [String] {
        var played: [String] = []
        while played.count < limit, let track = player.current {
            played.append(track)
            player.trackDidFinish()
        }
        return played
    }

    @Test("In order, with repeat off, every track plays once and then the queue ends")
    func inOrder() {
        var player = Queue.Player(tracks: album)
        let played = playThrough(&player)
        #expect(played == album)
        #expect(player.current == nil)
    }

    @Test("Repeat all starts again after the last track")
    func repeatAll() {
        var player = Queue.Player(tracks: album, repeatMode: .all)
        let played = playThrough(&player, limit: 6)
        #expect(played == album + ["Intro", "Ocean"])
    }

    @Test("Repeat one replays the track, but a skip still moves on")
    func repeatOne() {
        var player = Queue.Player(tracks: album, repeatMode: .one)
        player.trackDidFinish()
        player.trackDidFinish()
        #expect(player.current == "Intro")
        let skipped = skip(1, on: &player)
        #expect(skipped == [true])
        #expect(player.current == "Ocean")
    }

    @Test("Skipping past the last track ends the queue, unless repeat all wraps round")
    func skipAtTheEnd() {
        var stops = Queue.Player(tracks: ["A", "B"])
        let stopping = skip(3, on: &stops)
        #expect(stopping == [true, true, false])
        #expect(stops.current == nil)

        var wraps = Queue.Player(tracks: ["A", "B"], repeatMode: .all)
        let wrapping = skip(2, on: &wraps)
        #expect(wrapping == [true, true])
        #expect(wraps.current == "A")
    }

    @Test("Shuffled plays every track exactly once, the same way for the same seed")
    func shuffled() {
        let tracks = (1...12).map { "Track \($0)" }
        var first = Queue.Player(tracks: tracks, ordering: Queue.Shuffled(seed: 7))
        var again = Queue.Player(tracks: tracks, ordering: Queue.Shuffled(seed: 7))
        var other = Queue.Player(tracks: tracks, ordering: Queue.Shuffled(seed: 8))
        let order = playThrough(&first)
        #expect(order.sorted() == tracks.sorted())
        #expect(order != tracks)
        let sameSeed = playThrough(&again)
        let otherSeed = playThrough(&other)
        #expect(sameSeed == order)
        #expect(otherSeed != order)
    }

    @Test("Shuffle and repeat all combine: the second pass replays the shuffled order")
    func shuffledAndRepeated() {
        var player = Queue.Player(tracks: album, ordering: Queue.Shuffled(seed: 3), repeatMode: .all)
        let twoPasses = playThrough(&player, limit: 8)
        #expect(twoPasses.count == 8)
        #expect(Array(twoPasses.prefix(4)).sorted() == album.sorted())
        #expect(Array(twoPasses.suffix(4)) == Array(twoPasses.prefix(4)))
    }

    @Test("Skips are unlimited by default")
    func unlimitedSkips() {
        var player = Queue.Player(tracks: ["Loop"], repeatMode: .all)
        let skipped = skip(50, on: &player)
        #expect(skipped == Array(repeating: true, count: 50))
        #expect(player.current == "Loop")
    }

    @Test("A limited allowance refuses skips once it's used up, and the track doesn't change")
    func limitedSkips() {
        var player = Queue.Player(tracks: album, skips: Queue.LimitedSkips(2))
        let skipped = skip(3, on: &player)
        #expect(skipped == [true, true, false])
        #expect(player.current == "Lights")
        player.trackDidFinish()
        #expect(player.current == "Outro")
    }

    @Test("Trying to skip with nothing playing doesn't use up the allowance")
    func skipWithNothingPlaying() {
        var empty = Queue.Player(tracks: [], skips: Queue.LimitedSkips(1))
        let emptySkip = skip(1, on: &empty)
        #expect(empty.current == nil)
        #expect(emptySkip == [false])

        var ended = Queue.Player(tracks: ["Only"], skips: Queue.LimitedSkips(1))
        ended.trackDidFinish()
        let endedSkip = skip(1, on: &ended)
        #expect(endedSkip == [false])
    }

    @Test("A new ordering is a new part: the player works with one it has never seen")
    func customOrdering() {
        struct Reversed: PrinciplesPlaybackQueue.Ordering {
            func arrange(_ tracks: [String]) -> [String] { tracks.reversed() }
        }
        var player = Queue.Player(tracks: album, ordering: Reversed(), repeatMode: .all, skips: Queue.LimitedSkips(1))
        #expect(player.current == "Outro")
        let skipped = skip(2, on: &player)
        #expect(skipped == [true, false])
        let played = playThrough(&player, limit: 4)
        #expect(played == ["Lights", "Ocean", "Intro", "Outro"])
    }

    @Test("A new skip allowance is a new part too")
    func customAllowance() {
        struct EveryOtherSkip: PrinciplesPlaybackQueue.SkipAllowance {
            var attempts = 0
            mutating func useSkip() -> Bool {
                attempts += 1
                return attempts % 2 == 1
            }
        }
        var player = Queue.Player(tracks: album, skips: EveryOtherSkip())
        let skipped = skip(3, on: &player)
        #expect(skipped == [true, false, true])
        #expect(player.current == "Lights")
    }
}
