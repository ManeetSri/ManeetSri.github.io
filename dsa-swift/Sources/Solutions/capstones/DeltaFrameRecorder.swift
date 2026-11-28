// Reference solution: delta frame recorder. Run insertion sort once, writing one small Step per frame
// and a full copy of the values (a keyframe) whenever the frame number is a multiple of the interval.
// To show frame i, copy keyframe i / interval and replay the swaps between it and frame i. Memory is
// O(frames + frames / interval × n) instead of O(frames × n), and each frame costs O(n + interval).

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

        public init(sorting input: [Int], keyframeEvery interval: Int) {
            self.interval = interval
            var items = input
            record(.start, items)
            for i in stride(from: 1, to: items.count, by: 1) {     // stride: empty, never a bad range
                var j = i
                while j > 0 {
                    record(.compare(j), items)
                    guard items[j - 1] > items[j] else { break }
                    items.swapAt(j - 1, j)
                    record(.swap(j), items)
                    j -= 1
                }
            }
            record(.finish, items)
        }

        private mutating func record(_ step: Step, _ items: [Int]) {
            if steps.count % interval == 0 { keyframes.append(items) }
            steps.append(step)
        }

        public var frameCount: Int { steps.count }

        public func frame(at index: Int) -> Frame {
            let key = index / interval
            var values = keyframes[key]
            for position in stride(from: key * interval + 1, through: index, by: 1) {
                if case .swap(let j) = steps[position] { values.swapAt(j - 1, j) }
            }
            switch steps[index] {
            case .compare(let j), .swap(let j):
                return Frame(values: values, active: [j - 1, j])
            case .start, .finish:
                return Frame(values: values, active: [])
            }
        }
    }
}
