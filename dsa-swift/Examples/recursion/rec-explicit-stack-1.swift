// Generated from src/dsa/content/lessons/recursion/rec-explicit-stack.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sumWithStack(_ n: Int) -> Int {
    var pending: [Int] = []                  // the "frames" waiting for an answer
    var current = n
    while current > 0 {                      // going down: remember each n
        pending.append(current)
        current -= 1
    }

    var result = 0                           // the base case's answer
    while let value = pending.popLast() {    // coming back up: finish each call
        result = value + result
    }
    return result
}

print(sumWithStack(100))
print(sumWithStack(1_000_000))
