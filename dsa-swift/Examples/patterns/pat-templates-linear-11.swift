// Generated from src/dsa/content/lessons/patterns/pat-templates-linear.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Monotonic stack: how many days until a warmer one, and the nearest smaller value to the left
func daysUntilWarmer(_ temperatures: [Int]) -> [Int] {
    var wait = Array(repeating: 0, count: temperatures.count)
    var stack: [Int] = []                         // indexes still waiting; temperatures never rise going up
    for today in temperatures.indices {
        while let last = stack.last, temperatures[last] < temperatures[today] {
            stack.removeLast()
            wait[last] = today - last             // today is the answer for `last`
        }
        stack.append(today)
    }
    return wait                                   // anything left on the stack keeps 0
}

func previousSmaller(_ items: [Int]) -> [Int] {
    var result = Array(repeating: -1, count: items.count)
    var stack: [Int] = []                         // values strictly increase going up
    for i in items.indices {
        while let last = stack.last, items[last] >= items[i] {
            stack.removeLast()                    // can never be anyone's previous smaller again
        }
        if let last = stack.last { result[i] = items[last] }
        stack.append(i)
    }
    return result
}

print(daysUntilWarmer([15, 14, 16, 13, 12, 18, 17]))
print(previousSmaller([4, 6, 5, 2, 7, 5]))
