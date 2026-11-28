// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-object-pools.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

final class Pool<Resource: AnyObject> {
    private var idle: [Resource] = []
    private let make: () -> Resource
    private let reset: (Resource) -> Void
    private(set) var created = 0

    init(make: @escaping () -> Resource, reset: @escaping (Resource) -> Void) {
        self.make = make
        self.reset = reset
    }

    // Lend a resource for the length of `body`, and always take it back, even if body throws
    func borrow<T>(_ body: (Resource) throws -> T) rethrows -> T {
        let resource: Resource
        if let recycled = idle.popLast() {
            resource = recycled
        } else {
            created += 1
            resource = make()
        }
        defer {
            reset(resource)
            idle.append(resource)
        }
        return try body(resource)
    }
}

final class Scratchpad {
    var bytes: [UInt8] = []
}

let pool = Pool(make: { Scratchpad() }, reset: { $0.bytes.removeAll(keepingCapacity: true) })

for row in 0..<1_000 {
    pool.borrow { pad in pad.bytes.append(UInt8(row % 256)) }
}
print("1,000 borrows one after another:", pool.created, "created")

pool.borrow { outer in
    pool.borrow { inner in
        print("nested borrows get different objects:", outer !== inner)
    }
}
print("after nesting:", pool.created, "created")
