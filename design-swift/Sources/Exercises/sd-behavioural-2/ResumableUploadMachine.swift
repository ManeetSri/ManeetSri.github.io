// Kata: An upload state machine (D13 · State: enum state machines)
import Foundation

public enum ResumableUploadMachine {
    /// Where one photo upload is. Each state carries exactly the data that exists in it.
    public enum State: Equatable, Sendable {
        /// Not started yet
        case idle
        /// Sending attempt `attempt` (counting from 1); `sent` bytes have reached the server
        case uploading(attempt: Int, sent: Int)
        /// Paused by the user; resuming continues from byte `sent`
        case paused(attempt: Int, sent: Int)
        /// The network failed; attempt `attempt` starts when the retry timer fires
        case waitingToRetry(attempt: Int, sent: Int)
        /// The last allowed attempt failed
        case failed(reason: String)
        /// The server stored the photo
        case completed(remoteID: String)
        /// The user cancelled the upload
        case cancelled
    }

    /// What can happen: the user's taps, the upload task's callbacks and the retry timer
    public enum Event: Equatable, Sendable {
        case start
        case progress(sent: Int)
        case pause
        case resume
        case networkFailed
        case retryTimerFired
        case finished(remoteID: String)
        case cancel
    }

    /// What the machine asks the shell to do. The machine itself never touches the network or a timer.
    public enum Effect: Equatable, Sendable {
        case beginUpload(attempt: Int, fromByte: Int)
        case suspendUpload
        case scheduleRetry(afterSeconds: Int)
        case cancelUpload
        case cancelRetryTimer
        case notifyCompleted(remoteID: String)
        case notifyFailed(reason: String)
    }

    public struct Machine: Sendable {
        /// Attempts allowed in total, including the first (at least 1)
        public let maxAttempts: Int
        public private(set) var state: State = .idle

        public init(maxAttempts: Int = 3) {
            self.maxAttempts = maxAttempts
        }

        /// Applies `event` and returns the effects to perform, in order. An event the current state
        /// doesn't handle changes nothing and returns no effects.
        public mutating func send(_ event: Event) -> [Effect] {
            // Write your solution here, then run:
            // swift test --filter ResumableUploadMachineTests
            return []
        }
    }
}
