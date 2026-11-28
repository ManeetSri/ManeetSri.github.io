// Generated from src/dsa/content/lessons/recursion/rec-multiple-recursion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func hanoiMoveCount(_ disks: Int) -> Int {
    if disks == 0 {
        return 0
    }
    return 2 * hanoiMoveCount(disks - 1) + 1
}

print("disks → moves")
for disks in [1, 2, 3, 10, 20] {
    print("\(disks) → \(hanoiMoveCount(disks))")
}
