// Generated from src/dsa/content/lessons/recursion/rec-vs-iteration.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func factorial(_ n: Int, soFar: Int = 1) -> Int {
    print("factorial(\(n), soFar: \(soFar))")
    if n <= 1 {
        return soFar
    }
    return factorial(n - 1, soFar: soFar * n)     // nothing left to do afterwards
}

print(factorial(4))
