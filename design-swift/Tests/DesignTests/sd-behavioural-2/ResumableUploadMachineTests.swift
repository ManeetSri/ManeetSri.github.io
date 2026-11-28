import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ResumableUploadMachineTests {
    typealias Machine = ResumableUploadMachine.Machine
    typealias Event = ResumableUploadMachine.Event

    /// A machine that has already handled `events`, ignoring their effects
    private func machine(after events: [Event], maxAttempts: Int = 3) -> Machine {
        var machine = Machine(maxAttempts: maxAttempts)
        for event in events { _ = machine.send(event) }
        return machine
    }

    @Test("A new machine is idle")
    func startsIdle() {
        #expect(Machine().state == .idle)
    }

    @Test("Start, progress and finish: the happy path")
    func happyPath() {
        var upload = Machine()
        #expect(upload.send(.start) == [.beginUpload(attempt: 1, fromByte: 0)])
        #expect(upload.state == .uploading(attempt: 1, sent: 0))

        #expect(upload.send(.progress(sent: 500)) == [])
        #expect(upload.state == .uploading(attempt: 1, sent: 500))

        #expect(upload.send(.finished(remoteID: "photo-81")) == [.notifyCompleted(remoteID: "photo-81")])
        #expect(upload.state == .completed(remoteID: "photo-81"))
    }

    @Test("Pausing suspends the upload, and resuming continues from the bytes already sent")
    func pauseAndResume() {
        var upload = machine(after: [.start, .progress(sent: 400)])
        #expect(upload.send(.pause) == [.suspendUpload])
        #expect(upload.state == .paused(attempt: 1, sent: 400))

        #expect(upload.send(.resume) == [.beginUpload(attempt: 1, fromByte: 400)])
        #expect(upload.state == .uploading(attempt: 1, sent: 400))
    }

    @Test("Failures retry after 1, then 2 seconds, resuming from the bytes sent, until the last attempt fails")
    func retriesThenGivesUp() {
        var upload = machine(after: [.start, .progress(sent: 100)])

        #expect(upload.send(.networkFailed) == [.scheduleRetry(afterSeconds: 1)])
        #expect(upload.state == .waitingToRetry(attempt: 2, sent: 100))
        #expect(upload.send(.retryTimerFired) == [.beginUpload(attempt: 2, fromByte: 100)])
        #expect(upload.state == .uploading(attempt: 2, sent: 100))

        #expect(upload.send(.progress(sent: 250)) == [])
        #expect(upload.send(.networkFailed) == [.scheduleRetry(afterSeconds: 2)])
        #expect(upload.state == .waitingToRetry(attempt: 3, sent: 250))
        #expect(upload.send(.retryTimerFired) == [.beginUpload(attempt: 3, fromByte: 250)])

        #expect(upload.send(.networkFailed) == [.notifyFailed(reason: "Gave up after attempt 3")])
        #expect(upload.state == .failed(reason: "Gave up after attempt 3"))
    }

    @Test("The retry delay doubles with each failed attempt")
    func delaysDouble() {
        var upload = machine(after: [.start], maxAttempts: 5)
        var delays: [ResumableUploadMachine.Effect] = []
        for _ in 1...4 {
            delays += upload.send(.networkFailed)
            _ = upload.send(.retryTimerFired)
        }
        #expect(delays == [1, 2, 4, 8].map { .scheduleRetry(afterSeconds: $0) })
    }

    @Test("With one attempt allowed, the first failure gives up")
    func singleAttempt() {
        var upload = machine(after: [.start], maxAttempts: 1)
        #expect(upload.send(.networkFailed) == [.notifyFailed(reason: "Gave up after attempt 1")])
        #expect(upload.state == .failed(reason: "Gave up after attempt 1"))
    }

    @Test("Starting again after giving up begins a fresh first attempt")
    func tryAgain() {
        var upload = machine(after: [.start, .progress(sent: 900), .networkFailed], maxAttempts: 1)
        #expect(upload.send(.start) == [.beginUpload(attempt: 1, fromByte: 0)])
        #expect(upload.state == .uploading(attempt: 1, sent: 0))
    }

    @Test("A finish that arrives moments after pausing still completes the upload")
    func finishedWhilePaused() {
        var upload = machine(after: [.start, .pause])
        #expect(upload.send(.finished(remoteID: "photo-82")) == [.notifyCompleted(remoteID: "photo-82")])
        #expect(upload.state == .completed(remoteID: "photo-82"))
    }

    static let cancellations: [(setup: [Event], effects: [ResumableUploadMachine.Effect])] = [
        ([], []),
        ([.start, .progress(sent: 10)], [.cancelUpload]),
        ([.start, .pause], [.cancelUpload]),
        ([.start, .networkFailed], [.cancelRetryTimer]),
    ]

    @Test("Cancel works from every state that hasn't ended, and stops whatever is in flight", arguments: cancellations)
    func cancel(setup: [Event], effects: [ResumableUploadMachine.Effect]) {
        var upload = machine(after: setup)
        #expect(upload.send(.cancel) == effects)
        #expect(upload.state == .cancelled)
    }

    static let ignored: [(setup: [Event], expected: ResumableUploadMachine.State, event: Event)] = [
        ([], .idle, .progress(sent: 10)),
        ([], .idle, .resume),
        ([], .idle, .finished(remoteID: "x")),
        ([.start], .uploading(attempt: 1, sent: 0), .start),
        ([.start], .uploading(attempt: 1, sent: 0), .resume),
        ([.start], .uploading(attempt: 1, sent: 0), .retryTimerFired),
        ([.start, .pause], .paused(attempt: 1, sent: 0), .progress(sent: 50)),
        ([.start, .pause], .paused(attempt: 1, sent: 0), .networkFailed),
        ([.start, .pause], .paused(attempt: 1, sent: 0), .pause),
        ([.start, .networkFailed], .waitingToRetry(attempt: 2, sent: 0), .progress(sent: 50)),
        ([.start, .networkFailed], .waitingToRetry(attempt: 2, sent: 0), .resume),
        ([.start, .finished(remoteID: "p")], .completed(remoteID: "p"), .start),
        ([.start, .finished(remoteID: "p")], .completed(remoteID: "p"), .cancel),
        ([.start, .cancel], .cancelled, .start),
        ([.start, .cancel], .cancelled, .resume),
    ]

    @Test("Events a state doesn't handle change nothing and ask for nothing", arguments: ignored)
    func ignoresEvents(setup: [Event], expected: ResumableUploadMachine.State, event: Event) {
        var upload = machine(after: setup)
        #expect(upload.state == expected)
        #expect(upload.send(event) == [])
        #expect(upload.state == expected)
    }

    @Test("A failed upload ignores everything except starting again")
    func failedIgnoresOthers() {
        var upload = machine(after: [.start, .networkFailed], maxAttempts: 1)
        let failed = upload.state
        #expect(failed == .failed(reason: "Gave up after attempt 1"))
        for event: Event in [.cancel, .resume, .retryTimerFired, .progress(sent: 5), .pause] {
            #expect(upload.send(event) == [])
            #expect(upload.state == failed)
        }
    }
}
