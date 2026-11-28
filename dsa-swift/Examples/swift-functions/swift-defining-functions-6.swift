// Generated from src/dsa/content/lessons/swift-functions/swift-defining-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func printReceipt(total: Int) {
    guard total > 0 else {
        print("Nothing to pay.")
        return
    }
    print("Please pay £\(total).")
}

printReceipt(total: 0)
printReceipt(total: 12)
