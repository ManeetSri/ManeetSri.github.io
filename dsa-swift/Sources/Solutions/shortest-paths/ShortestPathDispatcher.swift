// Reference solution: Pick the right shortest-path algorithm. One pass over the weights and one run of
// Kahn's algorithm answer the decision table's questions, top row first: all weights equal and
// positive (BFS, then hops × weight), only 0s and 1s (0-1 BFS with a deque), no cycle (relax in the
// topological order Kahn produced), no negative weight (Dijkstra with a heap), otherwise Bellman–Ford.
// Classifying is O(nodes + edges); each method then runs in its own time from the table.

import DSAKit

public enum ShortestPathDispatcher {
    public enum Method: Sendable, CaseIterable {
        case bfs
        case zeroOneBFS
        case dagOrder
        case dijkstra
        case bellmanFord
    }

    private typealias Graph = [[(to: Int, weight: Int)]]
    private static let infinity = Int.max / 2                // "not reached", with room to add a weight

    public static func route(nodes: Int, edges: [[Int]], source: Int) -> (method: Method, distances: [Int?]) {
        var graph: Graph = Array(repeating: [], count: nodes)
        for edge in edges {
            graph[edge[0]].append((edge[1], edge[2]))
        }
        let weights = edges.map { $0[2] }
        var distance = Array(repeating: infinity, count: nodes)
        distance[source] = 0
        let method: Method

        if weights.isEmpty || (weights[0] >= 1 && weights.allSatisfy { $0 == weights[0] }) {
            method = .bfs
            bfs(graph, from: source, weight: weights.first ?? 1, &distance)
        } else if weights.allSatisfy({ $0 == 0 || $0 == 1 }) {
            method = .zeroOneBFS
            zeroOneBFS(graph, from: source, &distance)
        } else if let order = topologicalOrder(graph) {
            method = .dagOrder
            for node in order where distance[node] != infinity {
                for (next, weight) in graph[node] {
                    distance[next] = min(distance[next], distance[node] + weight)
                }
            }
        } else if weights.allSatisfy({ $0 >= 0 }) {
            method = .dijkstra
            dijkstra(graph, from: source, &distance)
        } else {
            method = .bellmanFord
            bellmanFord(edges, nodes: nodes, &distance)
        }
        return (method, distance.map { $0 == infinity ? nil : $0 })
    }

    /// Every edge costs `weight`: the first visit is the fewest hops, so distance is hops × weight
    private static func bfs(_ graph: Graph, from source: Int, weight: Int, _ distance: inout [Int]) {
        var queue = [source]
        var head = 0
        while head < queue.count {
            let node = queue[head]
            head += 1
            for (next, _) in graph[node] where distance[next] == infinity {
                distance[next] = distance[node] + weight
                queue.append(next)
            }
        }
    }

    /// Weights 0 and 1: a 0-edge goes to the front of the deque, a 1-edge to the back
    private static func zeroOneBFS(_ graph: Graph, from source: Int, _ distance: inout [Int]) {
        var deque = Deque([source])
        while let node = deque.popFirst() {
            for (next, weight) in graph[node] where distance[node] + weight < distance[next] {
                distance[next] = distance[node] + weight
                if weight == 0 { deque.prepend(next) } else { deque.append(next) }
            }
        }
    }

    /// Kahn's algorithm: an order in which every edge points forwards, or nil if there's a cycle
    private static func topologicalOrder(_ graph: Graph) -> [Int]? {
        var inDegree = Array(repeating: 0, count: graph.count)
        for edges in graph {
            for (next, _) in edges { inDegree[next] += 1 }
        }
        var order = graph.indices.filter { inDegree[$0] == 0 }
        var head = 0
        while head < order.count {
            let node = order[head]
            head += 1
            for (next, _) in graph[node] {
                inDegree[next] -= 1
                if inDegree[next] == 0 { order.append(next) }
            }
        }
        return order.count == graph.count ? order : nil
    }

    /// Non-negative weights: settle the closest node first, skipping stale heap entries
    private static func dijkstra(_ graph: Graph, from source: Int, _ distance: inout [Int]) {
        var heap = Heap<(distance: Int, node: Int)>(areInIncreasingOrder: { $0.distance < $1.distance })
        heap.insert((0, source))
        while let (best, node) = heap.pop() {
            if best > distance[node] { continue }
            for (next, weight) in graph[node] where best + weight < distance[next] {
                distance[next] = best + weight
                heap.insert((distance[next], next))
            }
        }
    }

    /// Negative weights but no negative cycle: at most nodes - 1 rounds, stopping when nothing changes
    private static func bellmanFord(_ edges: [[Int]], nodes: Int, _ distance: inout [Int]) {
        for _ in 0..<max(nodes - 1, 0) {
            var changed = false
            for edge in edges where distance[edge[0]] != infinity && distance[edge[0]] + edge[2] < distance[edge[1]] {
                distance[edge[1]] = distance[edge[0]] + edge[2]
                changed = true
            }
            if !changed { break }
        }
    }
}
