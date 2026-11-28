import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct UploadResizePolicyTests {
    typealias Photo = UploadResizePolicy.Photo
    typealias Plan = UploadResizePolicy.Plan
    typealias Network = UploadResizePolicy.Network

    private let wifi = Network()
    private let cellular = Network(isExpensive: true)
    private let lowData = Network(isConstrained: true)
    private let lowDataOnCellular = Network(isExpensive: true, isConstrained: true)

    @Test("Original keeps the photo's size at full quality")
    func original() {
        let plan = UploadResizePolicy.Original().plan(for: Photo(width: 4032, height: 3024), on: cellular)
        #expect(plan == Plan(width: 4032, height: 3024, quality: 1))
    }

    @Test("FitWithin scales the longer side down to the limit and keeps the shape", arguments: [
        (Photo(width: 4032, height: 3024), Plan(width: 2048, height: 1536, quality: 0.8)),
        (Photo(width: 3024, height: 4032), Plan(width: 1536, height: 2048, quality: 0.8)),
        (Photo(width: 4096, height: 4096), Plan(width: 2048, height: 2048, quality: 0.8)),
        (Photo(width: 12000, height: 3000), Plan(width: 2048, height: 512, quality: 0.8)),
    ])
    func fitWithin(photo: Photo, expected: Plan) {
        #expect(UploadResizePolicy.FitWithin(maxSide: 2048, quality: 0.8).plan(for: photo, on: wifi) == expected)
    }

    @Test("FitWithin never scales a small photo up")
    func noUpscaling() {
        let strategy = UploadResizePolicy.FitWithin(maxSide: 2048, quality: 0.7)
        #expect(strategy.plan(for: Photo(width: 800, height: 600), on: wifi) == Plan(width: 800, height: 600, quality: 0.7))
        #expect(strategy.plan(for: Photo(width: 2048, height: 10), on: wifi) == Plan(width: 2048, height: 10, quality: 0.7))
    }

    @Test("FitWithin rounds halves up and never makes a side zero")
    func rounding() {
        let strategy = UploadResizePolicy.FitWithin(maxSide: 500, quality: 0.5)
        #expect(strategy.plan(for: Photo(width: 1000, height: 333), on: wifi) == Plan(width: 500, height: 167, quality: 0.5))
        #expect(strategy.plan(for: Photo(width: 1000, height: 331), on: wifi) == Plan(width: 500, height: 166, quality: 0.5))
        #expect(strategy.plan(for: Photo(width: 40000, height: 1), on: wifi) == Plan(width: 500, height: 1, quality: 0.5))
    }

    @Test("ByNetwork picks a strategy from the network, and Low Data Mode wins over cellular")
    func byNetwork() {
        let strategy = UploadResizePolicy.ByNetwork(
            unmetered: UploadResizePolicy.Original(),
            cellular: UploadResizePolicy.FitWithin(maxSide: 2048, quality: 0.8),
            lowData: UploadResizePolicy.FitWithin(maxSide: 1024, quality: 0.6)
        )
        let photo = Photo(width: 4032, height: 3024)
        #expect(strategy.plan(for: photo, on: wifi) == Plan(width: 4032, height: 3024, quality: 1))
        #expect(strategy.plan(for: photo, on: cellular) == Plan(width: 2048, height: 1536, quality: 0.8))
        #expect(strategy.plan(for: photo, on: lowData) == Plan(width: 1024, height: 768, quality: 0.6))
        #expect(strategy.plan(for: photo, on: lowDataOnCellular) == Plan(width: 1024, height: 768, quality: 0.6))
    }

    @Test("Custom turns a closure into a strategy, and it sees the photo and the network")
    func custom() {
        let strategy = UploadResizePolicy.Custom { photo, network in
            Plan(width: photo.width / 2, height: photo.height / 2, quality: network.isExpensive ? 0.5 : 0.9)
        }
        #expect(strategy.plan(for: Photo(width: 100, height: 60), on: cellular) == Plan(width: 50, height: 30, quality: 0.5))
        #expect(strategy.plan(for: Photo(width: 100, height: 60), on: wifi) == Plan(width: 50, height: 30, quality: 0.9))
    }

    @Test("The queue plans every photo, in order, with whatever strategy it has now")
    func queueUsesCurrentStrategy() {
        var queue = UploadResizePolicy.UploadQueue(strategy: UploadResizePolicy.Original())
        queue.add(Photo(width: 4032, height: 3024))
        queue.add(Photo(width: 1000, height: 1000))
        #expect(queue.photos.count == 2)
        #expect(queue.plans(on: wifi) == [Plan(width: 4032, height: 3024, quality: 1), Plan(width: 1000, height: 1000, quality: 1)])

        queue.strategy = UploadResizePolicy.FitWithin(maxSide: 500, quality: 0.6)
        #expect(queue.plans(on: wifi) == [Plan(width: 500, height: 375, quality: 0.6), Plan(width: 500, height: 500, quality: 0.6)])
    }

    @Test("The queue works with any strategy, including ones it has never heard of")
    func queueWithUnknownStrategy() {
        let tiny = UploadResizePolicy.Custom { _, _ in Plan(width: 1, height: 1, quality: 0.1) }
        var queue = UploadResizePolicy.UploadQueue(strategy: tiny)
        queue.add(Photo(width: 10, height: 10))
        #expect(queue.plans(on: lowData) == [Plan(width: 1, height: 1, quality: 0.1)])
        #expect(queue.plans(on: wifi).count == 1)
    }
}
