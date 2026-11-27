// Generated from src/dsa/content/lessons/mst/mst-prim.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let names = ["A", "B", "C", "D", "E", "F"]
let none = Int.max                                   // no edge
let weight = [
    //  A     B     C     D     E     F
    [none,    4,    2, none, none, none],          // A
    [   4, none,    1,    5, none, none],          // B
    [   2,    1, none, none,   10, none],          // C
    [none,    5, none, none,    2,    6],          // D
    [none, none,   10,    2, none,    3],          // E
    [none, none, none,    6,    3, none],          // F
]

/// O(V²) Prim: cheapest[v] is the lightest known edge from the tree to v, and via[v] its other end
func densePrim(_ weight: [[Int]]) -> Int? {
    let n = weight.count
    var inTree = Array(repeating: false, count: n)
    var cheapest = Array(repeating: none, count: n)
    var via = Array(repeating: -1, count: n)
    cheapest[0] = 0
    var total = 0
    for _ in 0..<n {
        var next = -1                                // the outside vertex with the cheapest way in
        for v in 0..<n where !inTree[v] && (next == -1 || cheapest[v] < cheapest[next]) {
            next = v
        }
        if cheapest[next] == none { return nil }    // nothing left is reachable
        inTree[next] = true
        total += cheapest[next]
        if via[next] >= 0 {
            print("add \(names[next]) via \(names[via[next]])\(names[next]) \(cheapest[next])")
        }
        for v in 0..<n where !inTree[v] && weight[next][v] < cheapest[v] {
            cheapest[v] = weight[next][v]            // a cheaper way into v, through next
            via[v] = next
        }
    }
    return total
}

print("total weight:", densePrim(weight)!)
