// Generated from src/dsa/content/lessons/concurrent-structures/cc-data-races.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

actor Tally {
    private(set) var total = 0

    func add(_ amount: Int) {
        total += amount
    }
}

let tally = Tally()
await withTaskGroup(of: Void.self) { group in
    for _ in 0..<100 {
        group.addTask {
            for _ in 0..<1_000 {
                await tally.add(1)
            }
        }
    }
}
print(await tally.total)
