// Generated from src/dsa/content/lessons/swift-functions/swift-first-recursion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countdown(from n: Int) {
    if n == 0 {
        print("Liftoff!")
        return
    }
    print(n)
    countdown(from: n - 1)
}

countdown(from: 3)
