// Problem: Moving average of a stream (M27 · Stream problems: first unique, moving average)

public enum StreamMovingAverage {
    /// Averages the most recent values of a stream, one value at a time.
    public struct MovingAverage {
        // Write your solution here, then run:
        // swift test --filter StreamMovingAverageTests
        // Add whatever private storage you need.

        /// Creates an empty average over windows of `windowSize` values (at least 1).
        public init(windowSize: Int) {
        }

        /// Adds `value` to the stream and returns the average of the last `windowSize` values, or of
        /// every value so far if there are fewer than that.
        public mutating func next(_ value: Int) -> Double {
            return 0
        }
    }
}
