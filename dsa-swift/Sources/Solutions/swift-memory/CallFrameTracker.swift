// Reference solution: Tracking call frames. The stack is an array of frame sizes: a call pushes, a return
// pops the newest frame in one step. A running total avoids re-adding the frames. O(1) per event.

public enum CallFrameTracker {
    public struct Report: Equatable {
        public let peakBytes: Int
        public let peakDepth: Int
        public let overflowIndex: Int?

        public init(peakBytes: Int, peakDepth: Int, overflowIndex: Int?) {
            self.peakBytes = peakBytes
            self.peakDepth = peakDepth
            self.overflowIndex = overflowIndex
        }
    }

    public static func analyse(_ events: [String], limit: Int) -> Report {
        var frames: [Int] = []
        var inUse = 0
        var peakBytes = 0
        var peakDepth = 0

        for (index, event) in events.enumerated() {
            let words = event.split(separator: " ")
            if words[0] == "return" {
                inUse -= frames.removeLast()
                continue
            }
            let size = Int(words[2])!
            if inUse + size > limit {
                return Report(peakBytes: peakBytes, peakDepth: peakDepth, overflowIndex: index)
            }
            frames.append(size)
            inUse += size
            peakBytes = max(peakBytes, inUse)
            peakDepth = max(peakDepth, frames.count)
        }
        return Report(peakBytes: peakBytes, peakDepth: peakDepth, overflowIndex: nil)
    }
}
