// Generated from src/dsa/content/lessons/recursion/rec-warmups.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sumOfDigits(_ n: Int) -> Int {
    if n < 10 {
        return n
    }
    return n % 10 + sumOfDigits(n / 10)
}

func printDigits(_ n: Int) {
    if n >= 10 {
        printDigits(n / 10)            // print the front digits first...
    }
    print(n % 10, terminator: " ")     // ...then this one
}

print(sumOfDigits(905), sumOfDigits(98765))
printDigits(2026)
print()
