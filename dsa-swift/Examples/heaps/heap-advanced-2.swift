// Generated from src/dsa/content/lessons/heaps/heap-advanced.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// In a Fibonacci heap, a node with k children has at least F(k + 2) nodes in its subtree,
// so with n nodes no node can have more than about log_φ n children.
var fib = [0, 1]                                 // F(0), F(1), …
while fib.count < 40 {
    fib.append(fib[fib.count - 1] + fib[fib.count - 2])
}
for k in [0, 1, 2, 3, 4, 5, 10, 20] {
    print("degree \(k): subtree size at least \(fib[k + 2])")
}
let n = 1_000_000
var k = 0
while fib[k + 3] <= n {                          // the next degree, k + 1, still fits in n nodes
    k += 1
}
print("with \(n) nodes, the largest possible degree is \(k)")
