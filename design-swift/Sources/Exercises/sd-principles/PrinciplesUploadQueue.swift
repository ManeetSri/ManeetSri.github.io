// Kata: An upload queue workers can share (D05 · Command–query separation and CQRS basics)

public enum PrinciplesUploadQueue {
    /// What a worker receives when it claims a job: an immutable value, safe to hand to any task
    public struct Job: Sendable, Equatable {
        public let id: String
        public let fileName: String
        /// How many times this job has been claimed, counting this claim: 1 the first time
        public let attempt: Int

        public init(id: String, fileName: String, attempt: Int) {
            self.id = id
            self.fileName = fileName
            self.attempt = attempt
        }
    }

    public enum Status: Sendable, Equatable {
        /// In the line, waiting for a worker
        case waiting
        /// Claimed by a worker, on its `attempt`th try
        case uploading(attempt: Int)
        case done
        /// Used every attempt without succeeding
        case failed
    }

    /// The one owner of every job's status. Several workers share it.
    public actor Queue {
        /// `maxAttempts` is how many claims a job gets before it's marked failed (at least 1)
        public init(maxAttempts: Int = 3) {}

        // MARK: Queries: no side effects, so they're safe to call any number of times

        /// How many jobs are waiting to be claimed
        public var waitingCount: Int {
            0
        }

        /// A job's status, or `nil` if the queue has never seen the id
        public func status(of id: String) -> Status? {
            // Write your solution here, then run:
            // swift test --filter PrinciplesUploadQueueTests
            return nil
        }

        // MARK: Commands

        /// Adds a job to the back of the line. An id the queue already knows is ignored, whatever its status.
        public func enqueue(id: String, fileName: String) {}

        /// In one step, takes the job at the front of the line, marks it uploading and returns it. `nil`
        /// when nothing is waiting. This is a command that reports what it did, so claiming can't race.
        public func claimNext() -> Job? {
            return nil
        }

        /// The upload succeeded. Only an uploading job changes; for anything else this does nothing.
        public func complete(_ id: String) {}

        /// The upload failed. An uploading job goes to the back of the line to try again, or is marked
        /// failed once it has used `maxAttempts` claims. For anything else this does nothing.
        public func fail(_ id: String) {}
    }
}
