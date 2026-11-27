// Generated from src/dsa/content/lessons/recursion/rec-warmups.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func upTo(_ n: Int) {                       // parameter goes down, print after
    if n == 0 {
        return
    }
    upTo(n - 1)
    print(n, terminator: " ")
}

func upFrom(_ current: Int, to n: Int) {    // parameter goes up, print before
    if current > n {
        return
    }
    print(current, terminator: " ")
    upFrom(current + 1, to: n)
}

upTo(5)
print()
upFrom(1, to: 5)
print()
