// Generated from src/dsa/design/content/lessons/sd-resilience-patterns/sd-resilience-producer-consumer.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// Counts uploads in flight, so we can check the limit holds
actor InFlightGauge {
    private var current = 0
    private(set) var peak = 0

    func enter() {
        current += 1
        peak = max(peak, current)
    }

    func leave() {
        current -= 1
    }
}

func upload(_ photo: String, gauge: InFlightGauge) async -> String {
    await gauge.enter()
    await Task.yield() // stands in for the network
    await gauge.leave()
    return photo
}

// A worker pool in a task group: start `limit` uploads, then one more each time one finishes
func uploadAll(_ photos: [String], limit: Int, gauge: InFlightGauge) async -> [String] {
    await withTaskGroup(of: String.self) { group in
        var pending = photos.makeIterator()
        for _ in 0..<limit {
            guard let photo = pending.next() else { break }
            group.addTask { await upload(photo, gauge: gauge) }
        }
        var uploaded: [String] = []
        while let done = await group.next() {
            uploaded.append(done)
            if let photo = pending.next() {
                group.addTask { await upload(photo, gauge: gauge) }
            }
        }
        return uploaded
    }
}

let photos = (1...12).map { "IMG_\($0)" }
let gauge = InFlightGauge()
let uploaded = await uploadAll(photos, limit: 3, gauge: gauge)
print("Uploaded \(uploaded.count) of \(photos.count)")
print("Never more than 3 at once:", await gauge.peak <= 3)
