// Generated from src/dsa/content/lessons/fenwick/bit-lowbit.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The range each index is responsible for: the lowbit(i) positions ending at i
for i in 1...8 {
    let size = i & -i
    print("\(i): positions \(i - size + 1)...\(i)")
}
