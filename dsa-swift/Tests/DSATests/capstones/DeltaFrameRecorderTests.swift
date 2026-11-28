import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run sorts the same arrays
private struct FrameRecorderRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct DeltaFrameRecorderTests {
    typealias Frame = DeltaFrameRecorder.Frame
    typealias Step = DeltaFrameRecorder.Step
    typealias Recording = DeltaFrameRecorder.Recording

    /// The memory-hungry way, as in the lesson: a full snapshot for every frame
    private func snapshots(_ input: [Int]) -> [Frame] {
        var items = input
        var frames = [Frame(values: items, active: [])]
        for i in stride(from: 1, to: items.count, by: 1) {
            var j = i
            while j > 0 {
                frames.append(Frame(values: items, active: [j - 1, j]))
                guard items[j - 1] > items[j] else { break }
                items.swapAt(j - 1, j)
                frames.append(Frame(values: items, active: [j - 1, j]))
                j -= 1
            }
        }
        frames.append(Frame(values: items, active: []))
        return frames
    }

    /// The first mismatch between a recording and the full snapshots, if any
    private func firstMismatch(_ recording: Recording, _ expected: [Frame], interval: Int) -> String? {
        guard recording.frameCount == expected.count else {
            return "frameCount is \(recording.frameCount), expected \(expected.count)"
        }
        guard recording.steps.count == expected.count else {
            return "steps.count is \(recording.steps.count), expected one step per frame (\(expected.count))"
        }
        let keyframeCount = (expected.count - 1) / interval + 1
        guard recording.keyframes.count == keyframeCount else {
            return "\(recording.keyframes.count) keyframes, expected \(keyframeCount) for interval \(interval)"
        }
        for (k, keyframe) in recording.keyframes.enumerated() where keyframe != expected[k * interval].values {
            return "keyframe \(k) is \(keyframe), expected the values of frame \(k * interval): \(expected[k * interval].values)"
        }
        for (index, frame) in expected.enumerated() {
            let got = recording.frame(at: index)
            if got != frame { return "frame \(index) is \(got), expected \(frame)" }
        }
        return nil
    }

    @Test("Sorting [4, 2, 3, 1], as in the lesson")
    func lessonExample() {
        let recording = Recording(sorting: [4, 2, 3, 1], keyframeEvery: 5)
        #expect(recording.frameCount == 13)
        #expect(recording.steps == [.start, .compare(1), .swap(1), .compare(2), .swap(2), .compare(1),
                                    .compare(3), .swap(3), .compare(2), .swap(2), .compare(1), .swap(1), .finish])
        #expect(recording.keyframes == [[4, 2, 3, 1], [2, 3, 4, 1], [2, 1, 3, 4]])
        #expect(recording.frame(at: 0) == Frame(values: [4, 2, 3, 1], active: []))
        #expect(recording.frame(at: 2) == Frame(values: [2, 4, 3, 1], active: [0, 1]))
        #expect(recording.frame(at: 6) == Frame(values: [2, 3, 4, 1], active: [2, 3]))
        #expect(recording.frame(at: 9) == Frame(values: [2, 1, 3, 4], active: [1, 2]))
        #expect(recording.frame(at: 12) == Frame(values: [1, 2, 3, 4], active: []))
        #expect(firstMismatch(recording, snapshots([4, 2, 3, 1]), interval: 5) == nil)
    }

    @Test("Empty and one-value inputs give two frames: start and finish", arguments: [[], [7]] as [[Int]])
    func tiny(input: [Int]) {
        let recording = Recording(sorting: input, keyframeEvery: 3)
        #expect(recording.steps == [.start, .finish])
        #expect(recording.keyframes == [input])
        #expect(recording.frame(at: 0) == Frame(values: input, active: []))
        #expect(recording.frame(at: 1) == Frame(values: input, active: []))
    }

    @Test("Sorted input makes one comparison per value after the first, and no swaps")
    func sortedInput() {
        let recording = Recording(sorting: Array(1...20), keyframeEvery: 4)
        #expect(recording.frameCount == 21)
        #expect(recording.steps.filter { if case .swap = $0 { return true } else { return false } }.isEmpty)
        #expect(firstMismatch(recording, snapshots(Array(1...20)), interval: 4) == nil)
    }

    @Test("Equal values are never swapped")
    func equalValues() {
        let recording = Recording(sorting: [2, 2, 1, 2], keyframeEvery: 2)
        #expect(recording.steps == [.start, .compare(1), .compare(2), .swap(2), .compare(1), .swap(1),
                                    .compare(3), .finish])
        #expect(firstMismatch(recording, snapshots([2, 2, 1, 2]), interval: 2) == nil)
    }

    @Test("Every frame matches full snapshots, for random inputs and any interval", arguments: [1, 2, 3, 7, 50, 10_000])
    func randomInputs(interval: Int) {
        var random = FrameRecorderRandom(seed: UInt64(74 + interval))
        var mismatch: String? = nil
        for _ in 0..<60 where mismatch == nil {
            let input = (0..<Int.random(in: 0...12, using: &random)).map { _ in Int.random(in: -3...6, using: &random) }
            if let problem = firstMismatch(Recording(sorting: input, keyframeEvery: interval), snapshots(input), interval: interval) {
                mismatch = "\(input): \(problem)"
            }
        }
        #expect(mismatch == nil)
    }

    @Test("400 values in reverse order: about 160,000 frames, kept as steps and a few thousand keyframes")
    func large() {
        let n = 400
        let input = Array((1...n).reversed())
        let interval = 64
        let recording = Recording(sorting: input, keyframeEvery: interval)
        let expectedCount = 2 + n * (n - 1)                          // every pair compared and swapped once
        #expect(recording.frameCount == expectedCount)
        #expect(recording.keyframes.count == (expectedCount - 1) / interval + 1)
        guard recording.frameCount == expectedCount else { return }

        // Replay the sort once, checking 3,000 frames at random positions along the way
        var random = FrameRecorderRandom(seed: 400)
        let checks = Set((0..<3_000).map { _ in Int.random(in: 0..<expectedCount, using: &random) }).sorted()
        var items = input
        var index = 0
        var nextCheck = 0
        var mismatch: String? = nil
        func visit(_ active: [Int]) {
            if nextCheck < checks.count && checks[nextCheck] == index {
                let got = recording.frame(at: index)
                if mismatch == nil && got != Frame(values: items, active: active) {
                    mismatch = "frame \(index) has active \(got.active) and differs from the sort"
                }
                nextCheck += 1
            }
            index += 1
        }
        visit([])
        for i in 1..<n {
            var j = i
            while j > 0 {
                visit([j - 1, j])
                guard items[j - 1] > items[j] else { break }
                items.swapAt(j - 1, j)
                visit([j - 1, j])
                j -= 1
            }
        }
        visit([])
        #expect(mismatch == nil)
        #expect(recording.frame(at: expectedCount - 1).values == Array(1...n))
    }
}
