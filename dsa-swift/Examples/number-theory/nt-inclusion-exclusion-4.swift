// Generated from src/dsa/content/lessons/number-theory/nt-inclusion-exclusion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Onto functions from n items to k boxes: Σ (-1)^j · C(k, j) · (k - j)^n
func power(_ b: Int, _ e: Int) -> Int { e == 0 ? 1 : b * power(b, e - 1) }
func choose(_ n: Int, _ k: Int) -> Int {
    var result = 1
    for i in 0..<k { result = result * (n - i) / (i + 1) }
    return result
}
func onto(_ n: Int, _ k: Int) -> Int {
    (0...k).reduce(0) { total, j in total + (j % 2 == 0 ? 1 : -1) * choose(k, j) * power(k - j, n) }
}
print(onto(5, 3), onto(4, 2), onto(3, 5))
print(onto(5, 3) / 6, onto(4, 2) / 2)
