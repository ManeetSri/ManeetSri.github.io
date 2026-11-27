// Generated from src/dsa/content/lessons/backtracking/bk-maze-colouring.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countColourings(_ n: Int, _ edges: [[Int]], colours m: Int) -> Int {
    var neighbours = [[Int]](repeating: [], count: n)
    for edge in edges {
        neighbours[edge[0]].append(edge[1])
        neighbours[edge[1]].append(edge[0])
    }
    var colour = [Int](repeating: -1, count: n)            // -1: not coloured yet

    func paint(_ vertex: Int) -> Int {
        if vertex == n { return 1 }                         // every vertex coloured: one colouring
        var total = 0
        for c in 0..<m where !neighbours[vertex].contains(where: { colour[$0] == c }) {
            colour[vertex] = c                              // choose
            total += paint(vertex + 1)                      // explore
            colour[vertex] = -1                             // unchoose
        }
        return total
    }

    return paint(0)
}

let pentagon = [[0, 1], [1, 2], [2, 3], [3, 4], [4, 0]]
let square = [[0, 1], [1, 2], [2, 3], [3, 0]]
print(countColourings(5, pentagon, colours: 2), countColourings(5, pentagon, colours: 3))
print(countColourings(4, square, colours: 2), countColourings(4, square, colours: 3))
