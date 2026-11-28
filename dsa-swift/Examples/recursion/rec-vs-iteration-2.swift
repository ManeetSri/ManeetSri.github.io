// Generated from src/dsa/content/lessons/recursion/rec-vs-iteration.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func gcdRecursive(_ a: Int, _ b: Int) -> Int {
    if b == 0 {
        return a
    }
    return gcdRecursive(b, a % b)
}

func gcdLoop(_ a: Int, _ b: Int) -> Int {
    var (a, b) = (a, b)
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return a
}

print(gcdRecursive(1071, 462), gcdLoop(1071, 462))
