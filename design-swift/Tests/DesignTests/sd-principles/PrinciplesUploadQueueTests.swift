import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PrinciplesUploadQueueTests {
    typealias Uploads = PrinciplesUploadQueue

    @Test("Jobs are claimed oldest first, each once, with their attempt number")
    func claimOrder() async {
        let queue = Uploads.Queue()
        await queue.enqueue(id: "a", fileName: "IMG_0001.heic")
        await queue.enqueue(id: "b", fileName: "IMG_0002.heic")
        let first = await queue.claimNext()
        let second = await queue.claimNext()
        let third = await queue.claimNext()
        #expect(first == Uploads.Job(id: "a", fileName: "IMG_0001.heic", attempt: 1))
        #expect(second?.id == "b")
        #expect(third == nil)
        #expect(await queue.status(of: "a") == .uploading(attempt: 1))
        #expect(await queue.waitingCount == 0)
    }

    @Test("Asking a question never changes the answer")
    func queriesHaveNoSideEffects() async {
        let queue = Uploads.Queue()
        await queue.enqueue(id: "a", fileName: "a.mov")
        await queue.enqueue(id: "b", fileName: "b.mov")
        for _ in 0..<3 {
            #expect(await queue.waitingCount == 2)
            #expect(await queue.status(of: "a") == .waiting)
            #expect(await queue.status(of: "missing") == nil)
        }
        #expect(await queue.claimNext()?.id == "a")
        #expect(await queue.waitingCount == 1)
    }

    @Test("Enqueueing a known id again is ignored, whatever its status")
    func enqueueIsIdempotent() async {
        let queue = Uploads.Queue()
        await queue.enqueue(id: "a", fileName: "a.jpg")
        await queue.enqueue(id: "a", fileName: "a-copy.jpg")
        #expect(await queue.waitingCount == 1)
        #expect(await queue.claimNext()?.fileName == "a.jpg")

        await queue.enqueue(id: "a", fileName: "a.jpg")
        #expect(await queue.status(of: "a") == .uploading(attempt: 1))
        await queue.complete("a")
        await queue.enqueue(id: "a", fileName: "a.jpg")
        #expect(await queue.status(of: "a") == .done)
        #expect(await queue.waitingCount == 0)
    }

    @Test("A failed upload goes to the back of the line until it runs out of attempts")
    func retriesThenFails() async {
        let queue = Uploads.Queue(maxAttempts: 2)
        await queue.enqueue(id: "a", fileName: "a.jpg")
        await queue.enqueue(id: "b", fileName: "b.jpg")
        #expect(await queue.claimNext()?.id == "a")
        await queue.fail("a")
        #expect(await queue.status(of: "a") == .waiting)
        #expect(await queue.claimNext()?.id == "b")
        #expect(await queue.claimNext() == Uploads.Job(id: "a", fileName: "a.jpg", attempt: 2))
        await queue.fail("a")
        #expect(await queue.status(of: "a") == .failed)
        #expect(await queue.claimNext() == nil)
    }

    @Test("Commands that don't apply change nothing")
    func ignoredCommands() async {
        let queue = Uploads.Queue()
        await queue.enqueue(id: "a", fileName: "a.jpg")
        await queue.complete("a")
        await queue.fail("a")
        await queue.complete("missing")
        await queue.fail("missing")
        #expect(await queue.status(of: "a") == .waiting)
        #expect(await queue.waitingCount == 1)
        #expect(await queue.status(of: "missing") == nil)

        #expect(await queue.claimNext()?.id == "a")
        await queue.complete("a")
        await queue.complete("a")
        await queue.fail("a")
        #expect(await queue.status(of: "a") == .done)
        #expect(await queue.waitingCount == 0)
    }

    @Test("Many workers at once: every job is claimed exactly once")
    func concurrentWorkers() async {
        let queue = Uploads.Queue()
        let ids = (1...60).map { "photo-\($0)" }
        for id in ids {
            await queue.enqueue(id: id, fileName: "\(id).heic")
        }
        let claimed = await withTaskGroup(of: [String].self) { group in
            for _ in 0..<8 {
                group.addTask {
                    var mine: [String] = []
                    while let job = await queue.claimNext() {
                        mine.append(job.id)
                        await queue.complete(job.id)
                    }
                    return mine
                }
            }
            var all: [String] = []
            for await batch in group {
                all += batch
            }
            return all
        }
        #expect(claimed.count == ids.count)
        #expect(Set(claimed) == Set(ids))
        #expect(await queue.waitingCount == 0)
        var done = 0
        for id in ids where await queue.status(of: id) == .done {
            done += 1
        }
        #expect(done == ids.count)
    }
}
