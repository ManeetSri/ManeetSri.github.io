// Reference solution: An upload queue workers can share. Queries only read; commands only change, and
// return nothing, except claimNext, which must check and act in one step or two workers could take the
// same job. Each command ignores calls that don't apply, so retries and duplicates are harmless.

public enum PrinciplesUploadQueue {
    public struct Job: Sendable, Equatable {
        public let id: String
        public let fileName: String
        public let attempt: Int

        public init(id: String, fileName: String, attempt: Int) {
            self.id = id
            self.fileName = fileName
            self.attempt = attempt
        }
    }

    public enum Status: Sendable, Equatable {
        case waiting
        case uploading(attempt: Int)
        case done
        case failed
    }

    public actor Queue {
        private struct Entry {
            let fileName: String
            var status: Status
            var claims = 0
        }

        private let maxAttempts: Int
        private var entries: [String: Entry] = [:]
        private var line: [String] = []          // waiting ids, front first

        public init(maxAttempts: Int = 3) {
            self.maxAttempts = max(1, maxAttempts)
        }

        public var waitingCount: Int {
            line.count
        }

        public func status(of id: String) -> Status? {
            entries[id]?.status
        }

        public func enqueue(id: String, fileName: String) {
            guard entries[id] == nil else { return }
            entries[id] = Entry(fileName: fileName, status: .waiting)
            line.append(id)
        }

        public func claimNext() -> Job? {
            guard !line.isEmpty, var entry = entries[line[0]] else { return nil }
            let id = line.removeFirst()
            entry.claims += 1
            entry.status = .uploading(attempt: entry.claims)
            entries[id] = entry
            return Job(id: id, fileName: entry.fileName, attempt: entry.claims)
        }

        public func complete(_ id: String) {
            guard case .uploading = entries[id]?.status else { return }
            entries[id]?.status = .done
        }

        public func fail(_ id: String) {
            guard case .uploading(let attempt) = entries[id]?.status else { return }
            if attempt >= maxAttempts {
                entries[id]?.status = .failed
            } else {
                entries[id]?.status = .waiting
                line.append(id)
            }
        }
    }
}
