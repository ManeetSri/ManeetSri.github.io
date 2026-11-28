// Generated from src/dsa/content/lessons/bs-on-answer/bsa-kth-multiplication.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func entries(atMost x: Int, rows m: Int, columns n: Int) -> Int {
    var count = 0
    for i in 1...m {
        count += min(x / i, n)       // the multiples of i up to x, but at most n of them
    }
    return count
}

print((1...12).map { entries(atMost: $0, rows: 3, columns: 4) })
