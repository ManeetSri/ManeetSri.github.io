// Problem: Delta frame recorder (M74 · A SwiftUI sorting and pathfinding visualiser)

public enum DeltaFrameRecorder {
    /// What happened at one frame of insertion sort.
    public enum Step: Equatable {
        case start              // the input, before anything happens
        case compare(Int)       // positions j - 1 and j were compared
        case swap(Int)          // positions j - 1 and j were swapped
        case finish             // the sorted result
    }

    public struct Frame: Equatable {
        public let values: [Int]
        public let active: [Int]

        public init(values: [Int], active: [Int]) {
            self.values = values
            self.active = active
        }
    }

    public struct Recording {
        public let interval: Int
        /// One step per frame: steps[i] is what frame i shows.
        public private(set) var steps: [Step] = []
        /// keyframes[k] holds the values at frame k × interval.
        public private(set) var keyframes: [[Int]] = []

        /// Records insertion sort on `input`, keeping a full copy of the values every `interval` frames.
        public init(sorting input: [Int], keyframeEvery interval: Int) {
            // Write your solution here, then run:
            // swift test --filter DeltaFrameRecorderTests
            self.interval = interval
        }

        public var frameCount: Int { steps.count }

        /// Frame `index`, rebuilt from the nearest keyframe at or before it.
        public func frame(at index: Int) -> Frame {
            return Frame(values: [], active: [])
        }
    }
}
