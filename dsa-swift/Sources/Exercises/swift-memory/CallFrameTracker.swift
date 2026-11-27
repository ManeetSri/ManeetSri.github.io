// Problem: Tracking call frames (M11 · Stack vs heap)

public enum CallFrameTracker {
    public struct Report: Equatable {
        /// The most stack memory in use at any moment, in bytes.
        public let peakBytes: Int
        /// The most frames on the stack at any moment.
        public let peakDepth: Int
        /// The index of the call that overflowed the stack, or nil if none did.
        public let overflowIndex: Int?

        public init(peakBytes: Int, peakDepth: Int, overflowIndex: Int?) {
            self.peakBytes = peakBytes
            self.peakDepth = peakDepth
            self.overflowIndex = overflowIndex
        }
    }

    /// Replays `events` on a stack that holds at most `limit` bytes.
    ///
    /// - "call <name> <bytes>": pushes a frame of that many bytes.
    /// - "return": pops the newest frame.
    ///
    /// A call that would take the stack above `limit` overflows: the replay stops there, and the peaks
    /// are the ones reached before it.
    public static func analyse(_ events: [String], limit: Int) -> Report {
        // Write your solution here, then run:
        // swift test --filter CallFrameTrackerTests
        return Report(peakBytes: 0, peakDepth: 0, overflowIndex: nil)
    }
}
