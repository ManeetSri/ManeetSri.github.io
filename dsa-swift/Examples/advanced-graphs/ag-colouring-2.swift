// Generated from src/dsa/content/lessons/advanced-graphs/ag-colouring.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// m-colouring by backtracking: colour vertices in order, undo when a later vertex has no colour left
func colour(_ n: Int, _ edges: [[Int]], colours m: Int) -> [Int]? {
    var neighbours = [[Int]](repeating: [], count: n)
    for edge in edges {
        neighbours[edge[0]].append(edge[1])
        neighbours[edge[1]].append(edge[0])
    }
    var colour = [Int](repeating: -1, count: n)
    var attempts = 0

    func place(_ v: Int) -> Bool {
        if v == n { return true }                   // every vertex coloured
        for c in 0..<m {
            attempts += 1
            if neighbours[v].contains(where: { colour[$0] == c }) { continue }
            colour[v] = c                           // choose
            if place(v + 1) { return true }         // explore
        }
        colour[v] = -1                              // unchoose, and report failure
        return false
    }

    let found = place(0)
    print("  \(attempts) colour attempts")
    return found ? colour : nil
}

// The Petersen graph: an outer five-cycle, spokes, and an inner five-pointed star
let petersen = [[0, 1], [1, 2], [2, 3], [3, 4], [4, 0],
                [0, 5], [1, 6], [2, 7], [3, 8], [4, 9],
                [5, 7], [7, 9], [9, 6], [6, 8], [8, 5]]
for m in [2, 3] {
    print("Petersen with \(m) colours:")
    print(" ", colour(10, petersen, colours: m) as Any)
}
let k4 = [[0, 1], [0, 2], [0, 3], [1, 2], [1, 3], [2, 3]]
print("Four mutual neighbours with 3 colours:")
print(" ", colour(4, k4, colours: 3) as Any)
