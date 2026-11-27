// Generated from src/dsa/content/lessons/dp-foundations/dp-tabulation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func fib(_ n: Int) -> Int {
    if n < 2 {
        return n
    }
    var table = Array(repeating: 0, count: n + 1)   // table[i] = fib(i)
    table[1] = 1
    for i in 2...n {
        table[i] = table[i - 1] + table[i - 2]       // both already filled
    }
    print(table)
    return table[n]
}

print(fib(10))
