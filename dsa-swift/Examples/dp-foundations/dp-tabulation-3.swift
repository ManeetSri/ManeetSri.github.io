// Generated from src/dsa/content/lessons/dp-foundations/dp-tabulation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let size = 7
// ways[n][k]: the number of ways to choose k items from n
var ways = Array(repeating: Array(repeating: 0, count: size), count: size)
for n in 0..<size {
    ways[n][0] = 1                                   // choose nothing: one way
    for k in stride(from: 1, through: n, by: 1) {
        ways[n][k] = ways[n - 1][k - 1] + ways[n - 1][k]   // first item in, or out
    }
    print(ways[n][0...n].map(String.init).joined(separator: " "))
}
