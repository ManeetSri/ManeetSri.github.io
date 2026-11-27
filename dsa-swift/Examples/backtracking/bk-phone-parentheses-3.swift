// Generated from src/dsa/content/lessons/backtracking/bk-phone-parentheses.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countBalanced(_ n: Int) -> (strings: Int, nodes: Int) {
    var strings = 0
    var nodes = 0
    func explore(open: Int, close: Int) {
        nodes += 1
        if open + close == 2 * n {
            strings += 1
            return
        }
        if open < n { explore(open: open + 1, close: close) }
        if close < open { explore(open: open, close: close + 1) }
    }
    explore(open: 0, close: 0)
    return (strings, nodes)
}

for n in [3, 6, 10] {
    let (strings, nodes) = countBalanced(n)
    print("n = \(n): \(strings) balanced, \(nodes) nodes, \(1 << (2 * n)) raw strings")
}
