// Generated from src/dsa/content/lessons/swift-functions/swift-first-recursion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countDown(from n: Int) {
    if n == 0 { return }
    print(n)                 // work before the call
    countDown(from: n - 1)
}

func countUp(to n: Int) {
    if n == 0 { return }
    countUp(to: n - 1)
    print(n)                 // work after the call
}

countDown(from: 3)
print("---")
countUp(to: 3)
