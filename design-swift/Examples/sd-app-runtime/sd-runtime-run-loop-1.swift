// Generated from src/dsa/design/content/lessons/sd-app-runtime/sd-runtime-run-loop.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

// A synchronous check, so async code can show where it's running (for teaching, not for logic)
func whereAmI() -> String { Thread.isMainThread ? "the main thread" : "a pool thread" }

// Synchronous work runs on whatever thread calls it
func checksum(_ bytes: [UInt8]) -> Int {
    bytes.reduce(0) { $0 + Int($1) }
}

// @concurrent: runs on the thread pool, never on the caller's actor
@concurrent
func checksumOffMain(_ bytes: [UInt8]) async -> Int {
    print("2. checksum runs on \(whereAmI())")
    return checksum(bytes)
}

@MainActor
func refresh() async {
    print("1. refresh starts on \(whereAmI())")
    let bytes = [UInt8](repeating: 7, count: 1_000_000)
    let total = await checksumOffMain(bytes) // the main thread is free while this runs
    print("3. refresh resumes on \(whereAmI())")
    print("4. total \(total)")
}

await refresh()
