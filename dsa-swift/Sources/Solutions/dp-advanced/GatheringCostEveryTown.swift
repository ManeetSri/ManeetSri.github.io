// Reference solution: Gathering cost from every town. Rerooting. Root the tree at town 0 and list the
// towns parents-first with a BFS (no recursion, so a 100,000-town chain is fine). Down pass, children
// first: size[v] = towns in v's subtree, and down[v] = total distance from those towns to v; each child
// c with road length w adds down[c] + w · size[c]. Up pass, parents first: moving the meeting point
// from p across a road of length w to its child c brings c's size[c] towns w closer and takes the other
// n - size[c] towns w further, so answer[c] = answer[p] + w · (n - 2 · size[c]).
// O(n) time and space.

public enum GatheringCostEveryTown {
    public static func totalTravel(n: Int, roads: [[Int]]) -> [Int] {
        var neighbours = [[(to: Int, length: Int)]](repeating: [], count: n)
        for road in roads {
            neighbours[road[0]].append((road[1], road[2]))
            neighbours[road[1]].append((road[0], road[2]))
        }
        var parent = [Int](repeating: -1, count: n)
        var lengthUp = [Int](repeating: 0, count: n)       // length of the road from v to its parent
        var order = [0]
        var head = 0
        while head < order.count {
            let v = order[head]
            head += 1
            for (w, length) in neighbours[v] where w != parent[v] {
                parent[w] = v
                lengthUp[w] = length
                order.append(w)
            }
        }

        var size = [Int](repeating: 1, count: n)
        var down = [Int](repeating: 0, count: n)
        for v in order.reversed() where parent[v] >= 0 {
            size[parent[v]] += size[v]
            down[parent[v]] += down[v] + lengthUp[v] * size[v]
        }

        var answer = [Int](repeating: 0, count: n)
        answer[0] = down[0]
        for v in order where parent[v] >= 0 {
            answer[v] = answer[parent[v]] + lengthUp[v] * (n - 2 * size[v])
        }
        return answer
    }
}
