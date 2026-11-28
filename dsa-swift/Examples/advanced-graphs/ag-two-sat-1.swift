// Generated from src/dsa/content/lessons/advanced-graphs/ag-two-sat.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// 2-SAT: variable x is node 2x, its negation node 2x + 1. A code c ≥ 0 means x_c; ~c means ¬x_c.
func node(_ code: Int) -> Int { code >= 0 ? 2 * code : 2 * ~code + 1 }
func name(_ v: Int) -> String { v % 2 == 0 ? "x\(v / 2)" : "¬x\(v / 2)" }

func solve(_ n: Int, _ clauses: [[Int]]) -> [Bool]? {
    // Each clause (a or b) gives two implications: not a → b, and not b → a
    var implies = [[Int]](repeating: [], count: 2 * n)
    for clause in clauses {
        let a = node(clause[0]), b = node(clause[1])
        implies[a ^ 1].append(b)
        implies[b ^ 1].append(a)
    }
    let edges = (0..<(2 * n)).flatMap { v in implies[v].map { "\(name(v)) → \(name($0))" } }
    print("implications:", edges.joined(separator: ", "))

    // Tarjan's algorithm numbers components in the order they close: reverse topological order
    var index = [Int](repeating: -1, count: 2 * n)
    var low = [Int](repeating: 0, count: 2 * n)
    var component = [Int](repeating: -1, count: 2 * n)
    var onStack = [Bool](repeating: false, count: 2 * n)
    var stack: [Int] = []
    var nextIndex = 0
    var components = 0
    func visit(_ v: Int) {
        index[v] = nextIndex
        low[v] = nextIndex
        nextIndex += 1
        stack.append(v)
        onStack[v] = true
        for w in implies[v] {
            if index[w] == -1 {
                visit(w)
                low[v] = min(low[v], low[w])
            } else if onStack[w] {
                low[v] = min(low[v], index[w])
            }
        }
        if low[v] == index[v] {
            while true {
                let w = stack.removeLast()
                onStack[w] = false
                component[w] = components
                if w == v { break }
            }
            components += 1
        }
    }
    for v in 0..<(2 * n) where index[v] == -1 {
        visit(v)
    }

    var value = [Bool](repeating: false, count: n)
    for x in 0..<n {
        if component[2 * x] == component[2 * x + 1] {
            print("x\(x) and ¬x\(x) are in the same component: impossible")
            return nil
        }
        // Pick the literal whose component comes later in topological order: the smaller Tarjan number
        value[x] = component[2 * x] < component[2 * x + 1]
    }
    print("components:", (0..<(2 * n)).map { "\(name($0))=\(component[$0])" }.joined(separator: " "))
    return value
}

// Meetings 0, 1, 2; true means morning
let rules = [[0, 1], [~0, 2], [~1, ~2]]
if let plan = solve(3, rules) {
    print("plan:", plan)
    let kept = rules.allSatisfy { rule in rule.contains { $0 >= 0 ? plan[$0] : !plan[~$0] } }
    print("every rule kept:", kept)
}
print()
print(solve(3, [[0, 0], [~0, 1], [~1, 2], [~2, ~0]]) as Any)
