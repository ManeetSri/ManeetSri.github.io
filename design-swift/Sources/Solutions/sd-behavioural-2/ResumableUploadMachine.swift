// Reference solution: An upload state machine. One switch over (state, event) is the whole transition
// table; groups of states share a rule through a single case (cancel, finished), and the catch-all lists
// every state so a new one fails to compile until someone decides how it handles each event.
import Foundation

public enum ResumableUploadMachine {
    public enum State: Equatable, Sendable {
        case idle
        case uploading(attempt: Int, sent: Int)
        case paused(attempt: Int, sent: Int)
        case waitingToRetry(attempt: Int, sent: Int)
        case failed(reason: String)
        case completed(remoteID: String)
        case cancelled
    }

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
        public let maxAttempts: Int
        public private(set) var state: State = .idle

        public init(maxAttempts: Int = 3) {
            self.maxAttempts = maxAttempts
        }

        public mutating func send(_ event: Event) -> [Effect] {
            switch (state, event) {
            case (.idle, .start), (.failed, .start):
                state = .uploading(attempt: 1, sent: 0)
                return [.beginUpload(attempt: 1, fromByte: 0)]

            case (.uploading(let attempt, _), .progress(let sent)):
                state = .uploading(attempt: attempt, sent: sent)
                return []

            case (.uploading(let attempt, let sent), .pause):
                state = .paused(attempt: attempt, sent: sent)
                return [.suspendUpload]

            case (.paused(let attempt, let sent), .resume), (.waitingToRetry(let attempt, let sent), .retryTimerFired):
                state = .uploading(attempt: attempt, sent: sent)
                return [.beginUpload(attempt: attempt, fromByte: sent)]

            case (.uploading(let attempt, let sent), .networkFailed):
                guard attempt < maxAttempts else {
                    let reason = "Gave up after attempt \(attempt)"
                    state = .failed(reason: reason)
                    return [.notifyFailed(reason: reason)]
                }
                state = .waitingToRetry(attempt: attempt + 1, sent: sent)
                return [.scheduleRetry(afterSeconds: 1 << (attempt - 1))]

            // The server may answer moments before a pause takes effect: the photo is stored either way
            case (.uploading, .finished(let remoteID)), (.paused, .finished(let remoteID)):
                state = .completed(remoteID: remoteID)
                return [.notifyCompleted(remoteID: remoteID)]

            case (.idle, .cancel):
                state = .cancelled
                return []

            case (.uploading, .cancel), (.paused, .cancel):
                state = .cancelled
                return [.cancelUpload]

            case (.waitingToRetry, .cancel):
                state = .cancelled
                return [.cancelRetryTimer]

            case (.idle, _), (.uploading, _), (.paused, _), (.waitingToRetry, _), (.failed, _), (.completed, _), (.cancelled, _):
                return []
            }
        }
    }
}
