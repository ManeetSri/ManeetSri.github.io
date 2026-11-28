// Generated from src/dsa/content/lessons/recursion/rec-multiple-recursion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func printBinaryStrings(_ prefix: String, _ remaining: Int) {
    if remaining == 0 {
        print(prefix)                                  // a finished string
        return
    }
    printBinaryStrings(prefix + "0", remaining - 1)    // choice 1
    printBinaryStrings(prefix + "1", remaining - 1)    // choice 2
}

printBinaryStrings("", 3)
