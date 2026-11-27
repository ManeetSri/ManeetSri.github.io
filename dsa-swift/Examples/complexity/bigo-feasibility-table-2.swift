// Generated from src/dsa/content/lessons/complexity/bigo-feasibility-table.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

print(MemoryLayout<Int>.size, MemoryLayout<Bool>.size, MemoryLayout<Int32>.size)
let megabyte = 1_024 * 1_024
print(256 * megabyte / MemoryLayout<Int>.size)
for n in [1_000, 5_000, 10_000] {
    let bytes = n * n * MemoryLayout<Int>.size
    print("\(n) × \(n) grid of Int: \(bytes / megabyte) MB")
}
