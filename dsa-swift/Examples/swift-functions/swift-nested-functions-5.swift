// Generated from src/dsa/content/lessons/swift-functions/swift-nested-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func report(total: Int) {
    func describe(total: Int) -> String {
        "total is \(total)"
    }
    print(describe(total: 99))
    print("the outer total is \(total)")
}

report(total: 5)
