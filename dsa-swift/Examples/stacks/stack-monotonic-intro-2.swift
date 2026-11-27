// Generated from src/dsa/content/lessons/stacks/stack-monotonic-intro.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func previousSmaller(_ items: [Int]) -> [Int] {
    var result = Array(repeating: -1, count: items.count)
    var candidates: [Int] = []              // indexes, values increasing bottom to top
    for i in items.indices {
        while let top = candidates.last, items[top] >= items[i] {
            candidates.removeLast()          // never the answer for anything to the right again
        }
        if let top = candidates.last {
            result[i] = items[top]
        }
        candidates.append(i)
    }
    return result
}

print(previousSmaller([3, 7, 1, 7, 8, 4]))
