// Graph algorithms as frames. A graph is { directed, nodes: [{ id, x, y }], edges: [[from, to, weight]] }
// with x and y in 0–100. Frames: { states: { id: tone }, edges: { "a-b": tone }, labels: { id: text },
// side: [{ title, items }], line, message }.

export const GRAPHS = {
    small: {
        directed: false,
        nodes: [{ id: 'A', x: 10, y: 50 }, { id: 'B', x: 35, y: 18 }, { id: 'C', x: 35, y: 82 }, { id: 'D', x: 62, y: 18 }, { id: 'E', x: 62, y: 82 }, { id: 'F', x: 90, y: 50 }],
        edges: [['A', 'B'], ['A', 'C'], ['B', 'D'], ['C', 'E'], ['B', 'C'], ['D', 'F'], ['E', 'F']],
    },
    weighted: {
        directed: false,
        nodes: [{ id: 'A', x: 8, y: 50 }, { id: 'B', x: 34, y: 15 }, { id: 'C', x: 34, y: 85 }, { id: 'D', x: 64, y: 15 }, { id: 'E', x: 64, y: 85 }, { id: 'F', x: 92, y: 50 }],
        edges: [['A', 'B', 4], ['A', 'C', 2], ['B', 'C', 1], ['B', 'D', 5], ['C', 'E', 10], ['D', 'E', 2], ['D', 'F', 6], ['E', 'F', 3]],
    },
    // Directed, with a negative edge (B→A) that Dijkstra gets wrong: it settles A at 2 before B→A could lower it
    // to 1. The edges are listed in an unhelpful order, so Bellman–Ford needs a second round.
    negative: {
        directed: true,
        nodes: [{ id: 'S', x: 8, y: 50 }, { id: 'A', x: 38, y: 15 }, { id: 'B', x: 38, y: 85 }, { id: 'C', x: 66, y: 15 }, { id: 'D', x: 92, y: 50 }],
        edges: [['A', 'C', 3], ['C', 'D', 1], ['S', 'A', 2], ['S', 'B', 5], ['B', 'A', -4]],
    },
    // Directed, with three strongly connected components: {A, B, C}, {D, E} and {F}
    scc: {
        directed: true,
        nodes: [{ id: 'A', x: 8, y: 30 }, { id: 'B', x: 32, y: 12 }, { id: 'C', x: 32, y: 85 }, { id: 'D', x: 62, y: 12 }, { id: 'E', x: 62, y: 85 }, { id: 'F', x: 92, y: 50 }],
        edges: [['A', 'B'], ['B', 'C'], ['C', 'A'], ['B', 'D'], ['D', 'E'], ['E', 'D'], ['C', 'E'], ['E', 'F']],
    },
    // A flow network: capacities on directed edges, source S, sink T
    flow: {
        directed: true,
        nodes: [{ id: 'S', x: 5, y: 50 }, { id: 'A', x: 35, y: 12 }, { id: 'B', x: 35, y: 88 }, { id: 'C', x: 65, y: 12 }, { id: 'D', x: 65, y: 88 }, { id: 'T', x: 95, y: 50 }],
        edges: [['S', 'A', 10], ['S', 'B', 10], ['A', 'B', 2], ['A', 'C', 4], ['A', 'D', 8], ['B', 'D', 9], ['D', 'C', 6], ['C', 'T', 10], ['D', 'T', 10]],
    },
    dag: {
        directed: true,
        nodes: [{ id: 'shirt', x: 10, y: 20 }, { id: 'tie', x: 38, y: 20 }, { id: 'jacket', x: 66, y: 50 }, { id: 'trousers', x: 10, y: 80 }, { id: 'belt', x: 38, y: 80 }, { id: 'shoes', x: 92, y: 80 }, { id: 'socks', x: 92, y: 20 }],
        edges: [['shirt', 'tie'], ['tie', 'jacket'], ['shirt', 'belt'], ['trousers', 'belt'], ['belt', 'jacket'], ['trousers', 'shoes'], ['socks', 'shoes']],
    },
};

export const edgeKey = (a, b, directed) => (directed || a < b ? `${a}-${b}` : `${b}-${a}`);

const neighboursOf = (graph) => {
    const map = Object.fromEntries(graph.nodes.map((node) => [node.id, []]));
    graph.edges.forEach(([a, b, w = 1]) => {
        map[a].push({ to: b, weight: w });
        if (!graph.directed) map[b].push({ to: a, weight: w });
    });
    Object.values(map).forEach((list) => list.sort((x, y) => (x.to < y.to ? -1 : 1)));
    return map;
};

const CODE = {
    bfs: `func bfs(from start: Node, _ graph: [Node: [Node]]) -> [Node] {
    var visited: Set<Node> = [start]
    var queue = [start]
    var head = 0
    var order: [Node] = []
    while head < queue.count {
        let node = queue[head]
        head += 1
        order.append(node)
        for next in graph[node, default: []] where !visited.contains(next) {
            visited.insert(next)
            queue.append(next)
        }
    }
    return order
}`,
    dfs: `func dfs(_ node: Node, _ graph: [Node: [Node]], _ visited: inout Set<Node>, _ order: inout [Node]) {
    visited.insert(node)
    order.append(node)
    for next in graph[node, default: []] where !visited.contains(next) {
        dfs(next, graph, &visited, &order)
    }
}`,
    dijkstra: `func dijkstra(from source: Node, _ graph: [Node: [(Node, Int)]]) -> [Node: Int] {
    var distance: [Node: Int] = [source: 0]
    var heap = MinHeap<(Int, Node)>()
    heap.push((0, source))
    while let (dist, node) = heap.pop() {
        if dist > distance[node, default: .max] { continue }
        for (next, weight) in graph[node, default: []] {
            let candidate = dist + weight
            if candidate < distance[next, default: .max] {
                distance[next] = candidate
                heap.push((candidate, next))
            }
        }
    }
    return distance
}`,
    topo: `func topologicalOrder(_ graph: [Node: [Node]], _ nodes: [Node]) -> [Node]? {
    var inDegree = Dictionary(uniqueKeysWithValues: nodes.map { ($0, 0) })
    for targets in graph.values { for target in targets { inDegree[target]! += 1 } }
    var ready = nodes.filter { inDegree[$0] == 0 }
    var order: [Node] = []
    while !ready.isEmpty {
        let node = ready.removeFirst()
        order.append(node)
        for next in graph[node, default: []] {
            inDegree[next]! -= 1
            if inDegree[next] == 0 { ready.append(next) }
        }
    }
    return order.count == nodes.count ? order : nil
}`,
    prim: `func primTotal(_ graph: [Node: [(Node, Int)]], from start: Node) -> Int {
    var inTree: Set<Node> = []
    var heap = Heap<(weight: Int, from: Node, to: Node)> { $0.weight < $1.weight }
    heap.insert((0, start, start))
    var total = 0
    while let edge = heap.pop() {
        if inTree.contains(edge.to) { continue }    // a stale, heavier way in
        inTree.insert(edge.to)
        total += edge.weight
        for (next, weight) in graph[edge.to, default: []] where !inTree.contains(next) {
            heap.insert((weight, edge.to, next))
        }
    }
    return total
}`,
    bellmanFord: `func bellmanFord(_ edges: [(Node, Node, Int)], nodeCount: Int, from source: Node) -> [Node: Int]? {
    var distance: [Node: Int] = [source: 0]
    for _ in 0..<(nodeCount - 1) {
        for (from, to, weight) in edges {
            guard let d = distance[from] else { continue }   // not reached yet
            if d + weight < distance[to, default: .max] {
                distance[to] = d + weight
            }
        }
    }
    for (from, to, weight) in edges {           // one more round: does anything still improve?
        if let d = distance[from], d + weight < distance[to, default: .max] {
            return nil                          // a negative cycle is reachable
        }
    }
    return distance
}`,
    topoWaves: `func semesterPlan(_ courseCount: Int, _ prerequisites: [[Int]]) -> [[Int]]? {
    var unlocks = Array(repeating: [Int](), count: courseCount)
    var waitingOn = Array(repeating: 0, count: courseCount)
    for pair in prerequisites {                      // [before, after]
        unlocks[pair[0]].append(pair[1])
        waitingOn[pair[1]] += 1
    }
    var current = (0..<courseCount).filter { waitingOn[$0] == 0 }
    var plan: [[Int]] = []
    var taken = 0
    while !current.isEmpty {
        plan.append(current)                         // take everything that's ready, together
        taken += current.count
        var next: [Int] = []
        for course in current {
            for after in unlocks[course] {
                waitingOn[after] -= 1
                if waitingOn[after] == 0 {
                    next.append(after)               // ready next semester, not this one
                }
            }
        }
        current = next
    }
    return taken == courseCount ? plan : nil         // nil: a cycle blocks some courses
}`,
    topoDfs: `func topologicalOrder(_ graph: [Node: [Node]], _ nodes: [Node]) -> [Node] {
    var visited: Set<Node> = []
    var finished: [Node] = []
    func visit(_ node: Node) {
        visited.insert(node)
        for next in graph[node, default: []] where !visited.contains(next) { visit(next) }
        finished.append(node)                      // everything that must come after it is done
    }
    for node in nodes where !visited.contains(node) { visit(node) }
    return finished.reversed()
}`,
    scc: `func stronglyConnectedComponents(_ graph: [Node: [Node]], _ nodes: [Node]) -> [[Node]] {
    var visited: Set<Node> = []
    var finished: [Node] = []
    func firstPass(_ node: Node) {
        visited.insert(node)
        for next in graph[node, default: []] where !visited.contains(next) { firstPass(next) }
        finished.append(node)                      // everything reachable from node is done
    }
    for node in nodes where !visited.contains(node) { firstPass(node) }

    var reversed: [Node: [Node]] = [:]
    for (node, targets) in graph { for target in targets { reversed[target, default: []].append(node) } }
    var components: [[Node]] = []
    visited.removeAll()
    func secondPass(_ node: Node) {
        visited.insert(node)
        components[components.count - 1].append(node)
        for next in reversed[node, default: []] where !visited.contains(next) { secondPass(next) }
    }
    for node in finished.reversed() where !visited.contains(node) {
        components.append([])
        secondPass(node)                           // it reaches exactly one component
    }
    return components
}`,
    maxFlow: `func maxFlow(_ capacity: [[Int]], from source: Int, to sink: Int) -> Int {
    var residual = capacity                      // residual[u][v]: how much more can go u→v
    var total = 0
    while true {
        var parent = [Int](repeating: -1, count: capacity.count)
        parent[source] = source
        var queue = [source], head = 0
        while head < queue.count && parent[sink] == -1 {     // BFS: the shortest augmenting path
            let u = queue[head]; head += 1
            for v in residual.indices where parent[v] == -1 && residual[u][v] > 0 {
                parent[v] = u
                queue.append(v)
            }
        }
        if parent[sink] == -1 { return total }   // no path left: the flow is maximal
        var bottleneck = Int.max
        var v = sink
        while v != source { bottleneck = min(bottleneck, residual[parent[v]][v]); v = parent[v] }
        v = sink
        while v != source {
            residual[parent[v]][v] -= bottleneck
            residual[v][parent[v]] += bottleneck     // so the flow can be pushed back later
            v = parent[v]
        }
        total += bottleneck
    }
}`,
    kruskal: `func minimumSpanningTree(_ nodeCount: Int, _ edges: [(Int, Int, Int)]) -> [(Int, Int, Int)] {
    var sets = UnionFind(count: nodeCount)
    var tree: [(Int, Int, Int)] = []
    for edge in edges.sorted(by: { $0.2 < $1.2 }) {
        if sets.union(edge.0, edge.1) {
            tree.append(edge)
        }
    }
    return tree
}`,
};

function* bfs(graph, start) {
    const neighbours = neighboursOf(graph);
    const visited = new Set([start]);
    const level = { [start]: 0 };
    const queue = [start];
    const order = [];
    const edges = {};
    const frame = (line, message, current) => ({
        states: Object.fromEntries(graph.nodes.map((node) => [node.id, node.id === current ? 'current' : order.includes(node.id) ? 'done' : visited.has(node.id) ? 'frontier' : 'idle'])),
        edges: { ...edges },
        labels: { ...level },
        side: [{ title: 'queue (front first)', items: queue.slice(head) }, { title: 'visit order', items: [...order] }],
        line,
        message,
    });
    let head = 0;
    yield frame(3, `Start at ${start}: mark it visited and put it in the queue. Labels show each node's distance in edges.`);
    while (head < queue.length) {
        const node = queue[head];
        head += 1;
        order.push(node);
        yield frame(9, `Take ${node} from the front of the queue (distance ${level[node]}).`, node);
        for (const { to } of neighbours[node]) {
            if (visited.has(to)) continue;
            visited.add(to);
            level[to] = level[node] + 1;
            queue.push(to);
            edges[edgeKey(node, to, graph.directed)] = 'tree';
            yield frame(12, `${to} is new: it's ${level[to]} step${level[to] === 1 ? '' : 's'} from ${start}. Add it to the back of the queue.`, node);
        }
    }
    yield frame(15, `The queue is empty. BFS reached every node in order of distance: ${order.join(', ')}. The highlighted edges are shortest paths from ${start}.`);
}

function* dfs(graph, start) {
    const neighbours = neighboursOf(graph);
    const visited = new Set();
    const order = [];
    const stack = [];
    const edges = {};
    const frame = (line, message) => ({
        states: Object.fromEntries(graph.nodes.map((node) => [node.id, node.id === stack.at(-1) ? 'current' : stack.includes(node.id) ? 'frontier' : visited.has(node.id) ? 'done' : 'idle'])),
        edges: { ...edges },
        labels: Object.fromEntries(order.map((id, index) => [id, String(index + 1)])),
        side: [{ title: 'call stack (top last)', items: [...stack] }, { title: 'visit order', items: [...order] }],
        line,
        message,
    });
    function* visit(node, from) {
        visited.add(node);
        order.push(node);
        stack.push(node);
        if (from) edges[edgeKey(from, node, graph.directed)] = 'tree';
        yield frame(3, `Visit ${node}${from ? `, reached from ${from}` : ''}. Go as deep as possible before backing up.`);
        for (const { to } of neighbours[node]) {
            if (visited.has(to)) continue;
            yield* visit(to, node);
            yield frame(4, `Back in ${node}: try its next unvisited neighbour.`);
        }
        stack.pop();
    }
    yield* visit(start, null);
    yield frame(7, `Every reachable node is visited: ${order.join(', ')}. Numbers show the visiting order.`);
}

function* dijkstra(graph, start) {
    const neighbours = neighboursOf(graph);
    const distance = { [start]: 0 };
    const previous = {};
    const settled = new Set();
    const heap = [[0, start]];
    const edges = {};
    const labelOf = () => Object.fromEntries(graph.nodes.map((node) => [node.id, distance[node.id] === undefined ? '∞' : String(distance[node.id])]));
    const frame = (line, message, current) => ({
        states: Object.fromEntries(graph.nodes.map((node) => [node.id, node.id === current ? 'current' : settled.has(node.id) ? 'done' : distance[node.id] !== undefined ? 'frontier' : 'idle'])),
        edges: { ...edges },
        labels: labelOf(),
        side: [{ title: 'heap (smallest first)', items: [...heap].sort((a, b) => a[0] - b[0] || (a[1] < b[1] ? -1 : 1)).map(([d, n]) => `${n}:${d}`) }],
        line,
        message,
    });
    yield frame(4, `Distance to ${start} is 0; everything else starts at ∞. The heap always hands out the closest unsettled node.`);
    while (heap.length) {
        heap.sort((a, b) => a[0] - b[0] || (a[1] < b[1] ? -1 : 1));
        const [dist, node] = heap.shift();
        if (settled.has(node) || dist > distance[node]) {
            yield frame(6, `${node}:${dist} is stale (a shorter path was already found). Skip it.`, node);
            continue;
        }
        settled.add(node);
        if (previous[node]) edges[edgeKey(previous[node], node, graph.directed)] = 'tree';
        yield frame(5, `${node} is the closest unsettled node, at ${dist}. That distance is now final.`, node);
        for (const { to, weight } of neighbours[node]) {
            if (settled.has(to)) continue;
            const candidate = dist + weight;
            const old = distance[to];
            if (old === undefined || candidate < old) {
                distance[to] = candidate;
                previous[to] = node;
                heap.push([candidate, to]);
                yield frame(10, `Relax ${node}→${to}: ${dist} + ${weight} = ${candidate} beats ${old === undefined ? '∞' : old}. Update ${to}.`, node);
            } else {
                yield frame(9, `${node}→${to}: ${dist} + ${weight} = ${candidate} doesn't beat ${old}.`, node);
            }
        }
    }
    yield frame(15, `Done. Labels are the shortest distances from ${start}; highlighted edges form the shortest-path tree.`);
}

function* topo(graph) {
    const neighbours = neighboursOf(graph);
    const inDegree = Object.fromEntries(graph.nodes.map((node) => [node.id, 0]));
    graph.edges.forEach(([, to]) => { inDegree[to] += 1; });
    const ready = graph.nodes.filter((node) => inDegree[node.id] === 0).map((node) => node.id);
    const order = [];
    const edges = {};
    const frame = (line, message, current) => ({
        states: Object.fromEntries(graph.nodes.map((node) => [node.id, node.id === current ? 'current' : order.includes(node.id) ? 'done' : ready.includes(node.id) ? 'frontier' : 'idle'])),
        edges: { ...edges },
        labels: Object.fromEntries(graph.nodes.map((node) => [node.id, order.includes(node.id) ? `#${order.indexOf(node.id) + 1}` : `in ${inDegree[node.id]}`])),
        side: [{ title: 'ready (in-degree 0)', items: [...ready] }, { title: 'order', items: [...order] }],
        line,
        message,
    });
    yield frame(4, `Count each node's incoming edges. Nodes with none (${ready.join(', ')}) can go first.`);
    while (ready.length) {
        const node = ready.shift();
        order.push(node);
        yield frame(8, `Take ${node}: nothing still has to come before it.`, node);
        for (const { to } of neighbours[node]) {
            inDegree[to] -= 1;
            edges[edgeKey(node, to, true)] = 'used';
            if (inDegree[to] === 0) ready.push(to);
            yield frame(11, `Remove ${node}→${to}: ${to} now waits on ${inDegree[to]} more.${inDegree[to] === 0 ? ` It's ready.` : ''}`, node);
        }
    }
    yield frame(14, order.length === graph.nodes.length ? `A valid order: ${order.join(' → ')}.` : 'Some nodes never became ready: the graph has a cycle.');
}

function* kruskal(graph) {
    const parent = Object.fromEntries(graph.nodes.map((node) => [node.id, node.id]));
    const find = (x) => (parent[x] === x ? x : (parent[x] = find(parent[x])));
    const sorted = [...graph.edges].sort((a, b) => a[2] - b[2]);
    const edges = {};
    let total = 0;
    const frame = (line, message) => ({
        states: Object.fromEntries(graph.nodes.map((node) => [node.id, 'idle'])),
        edges: { ...edges },
        labels: Object.fromEntries(graph.nodes.map((node) => [node.id, `set ${find(node.id)}`])),
        side: [{ title: 'edges by weight', items: sorted.map(([a, b, w]) => `${a}${b}:${w}`) }, { title: 'total weight', items: [String(total)] }],
        line,
        message,
    });
    yield frame(4, 'Sort the edges by weight. Take each one unless its ends are already connected.');
    for (const [a, b, w] of sorted) {
        const key = edgeKey(a, b, false);
        if (find(a) !== find(b)) {
            parent[find(a)] = find(b);
            edges[key] = 'tree';
            total += w;
            yield frame(6, `${a}–${b} (${w}) joins two separate groups: keep it.`);
        } else {
            edges[key] = 'rejected';
            yield frame(5, `${a}–${b} (${w}) would close a cycle: ${a} and ${b} are already connected. Skip it.`);
        }
    }
    yield frame(10, `The minimum spanning tree uses ${Object.values(edges).filter((tone) => tone === 'tree').length} edges with a total weight of ${total}.`);
}

function* prim(graph, start) {
    const neighbours = neighboursOf(graph);
    const inTree = new Set();
    const heap = [[0, start, start]];
    const edges = {};
    let total = 0;
    const order = (entries) => [...entries].sort((a, b) => a[0] - b[0] || (a[2] < b[2] ? -1 : a[2] > b[2] ? 1 : 0));
    const frame = (line, message, current) => ({
        states: Object.fromEntries(graph.nodes.map((node) => [node.id, node.id === current ? 'current' : inTree.has(node.id) ? 'done' : heap.some((entry) => entry[2] === node.id) ? 'frontier' : 'idle'])),
        edges: { ...edges },
        labels: {},
        side: [{ title: 'heap (lightest first)', items: order(heap).map(([w, from, to]) => (from === to ? `${to}:${w}` : `${from}${to}:${w}`)) }, { title: 'total weight', items: [String(total)] }],
        line,
        message,
    });
    yield frame(4, `Grow one tree from ${start}. The heap holds every edge leaving the tree; the lightest one is always safe to add.`);
    while (heap.length) {
        const [weight, from, to] = order(heap)[0];
        heap.splice(heap.findIndex((entry) => entry[0] === weight && entry[1] === from && entry[2] === to), 1);
        if (inTree.has(to)) {
            edges[edgeKey(from, to, false)] = 'rejected';
            yield frame(7, `${from}–${to} (${weight}) is stale: ${to} is already in the tree by a lighter edge. Skip it.`, to);
            continue;
        }
        inTree.add(to);
        total += weight;
        if (from !== to) edges[edgeKey(from, to, false)] = 'tree';
        for (const { to: next, weight: w } of neighbours[to]) {
            if (!inTree.has(next)) heap.push([w, to, next]);
        }
        yield frame(11, from === to ? `Start the tree at ${to}, and push its edges.` : `Take ${from}–${to} (${weight}), the lightest edge leaving the tree. Push ${to}'s edges to nodes outside the tree.`, to);
    }
    yield frame(14, `Every node is in the tree. Total weight ${total}, the same as Kruskal's: the MST weight is unique even when the tree isn't.`);
}

function* bellmanFord(graph, start) {
    const distance = { [start]: 0 };
    const edges = {};
    const label = () => Object.fromEntries(graph.nodes.map((node) => [node.id, distance[node.id] === undefined ? '∞' : String(distance[node.id])]));
    const frame = (line, message, current, highlight) => ({
        states: Object.fromEntries(graph.nodes.map((node) => [node.id, node.id === current ? 'current' : distance[node.id] !== undefined ? 'done' : 'idle'])),
        edges: { ...edges, ...(highlight ? { [edgeKey(highlight[0], highlight[1], true)]: 'used' } : {}) },
        labels: label(),
        side: [{ title: 'edges, in the order they’re checked', items: graph.edges.map(([a, b, w]) => `${a}→${b}:${w}`) }],
        line,
        message,
    });
    const rounds = graph.nodes.length - 1;
    yield frame(2, `distance[${start}] = 0, every other node ∞. Relax every edge, ${rounds} times: after round k, every shortest path of up to k edges is correct.`);
    for (let round = 1; round <= rounds; round += 1) {
        let changed = 0;
        for (const [from, to, weight] of graph.edges) {
            if (distance[from] === undefined) continue;
            const candidate = distance[from] + weight;
            if (distance[to] === undefined || candidate < distance[to]) {
                const old = distance[to];
                distance[to] = candidate;
                changed += 1;
                yield frame(7, `Round ${round}: ${from}→${to} (${weight}): ${distance[from]} + ${weight} = ${candidate} beats ${old === undefined ? '∞' : old}.`, to, [from, to]);
            }
        }
        yield frame(3, changed ? `Round ${round} done: ${changed} distance${changed === 1 ? '' : 's'} improved.` : `Round ${round} changed nothing. The code still runs all ${rounds} rounds; stopping early here is a common, safe optimisation.`);
    }
    for (const [from, to, weight] of graph.edges) {
        if (distance[from] !== undefined && distance[from] + weight < distance[to]) {
            yield frame(13, `An extra round still improves ${from}→${to}: a negative cycle is reachable, so shortest distances don't exist.`, to, [from, to]);
            return;
        }
    }
    yield frame(16, `One more pass changes nothing, so there's no negative cycle. These are the shortest distances from ${start}, in O(V·E).`);
}

// DFS that records finishing order: a node finishes after everything reachable from it. Shared by topoDfs and scc.
function* finishingPass(graph, neighbours, finished, makeFrame, lines) {
    const visited = new Set();
    const stack = [];
    function* visit(node, from) {
        visited.add(node);
        stack.push(node);
        yield makeFrame(lines.visit, `Visit ${node}${from ? ` from ${from}` : ''}.`, { stack, visited, from: from && [from, node] });
        for (const { to } of neighbours[node]) {
            if (!visited.has(to)) yield* visit(to, node);
        }
        stack.pop();
        finished.push(node);
        yield makeFrame(lines.finish, `${node} finishes (#${finished.length}): everything reachable from it is done.`, { stack, visited, finishedNode: node });
    }
    for (const node of graph.nodes) {
        if (!visited.has(node.id)) yield* visit(node.id, null);
    }
}

// Kahn's algorithm in waves: everything ready now is taken together, and what it unlocks waits for the next wave
function* topoWaves(graph) {
    const ids = graph.nodes.map((node) => node.id);
    const unlocks = Object.fromEntries(ids.map((id) => [id, []]));
    const waitingOn = Object.fromEntries(ids.map((id) => [id, 0]));
    graph.edges.forEach(([before, after]) => { unlocks[before].push(after); waitingOn[after] += 1; });
    let current = ids.filter((id) => waitingOn[id] === 0);
    let next = [];
    const semester = {};
    const plan = [];
    const edges = {};
    const frame = (line, message, focus) => ({
        states: Object.fromEntries(ids.map((id) => [id, id === focus ? 'current' : semester[id] !== undefined && !current.includes(id) ? 'done' : current.includes(id) ? 'current' : next.includes(id) ? 'frontier' : 'idle'])),
        edges: { ...edges },
        labels: Object.fromEntries(ids.map((id) => [id, semester[id] !== undefined ? `S${semester[id]}` : `wait ${waitingOn[id]}`])),
        side: [{ title: 'this semester', items: [...current] }, { title: 'ready next', items: [...next] }, { title: 'plan', items: plan.map((wave, index) => `S${index + 1}: ${wave.join(' ')}`) }],
        line,
        message,
    });
    yield frame(8, `Count what each course waits on. ${current.join(', ')} wait${current.length === 1 ? 's' : ''} on nothing, so semester 1 takes ${current.length === 1 ? 'it' : 'them all at once'}.`);
    while (current.length) {
        plan.push([...current]);
        current.forEach((id) => { semester[id] = plan.length; });
        yield frame(12, `Semester ${plan.length}: take ${current.join(', ')} together.`);
        next = [];
        for (const course of current) {
            for (const after of unlocks[course]) {
                waitingOn[after] -= 1;
                edges[edgeKey(course, after, true)] = 'used';
                if (waitingOn[after] === 0) next.push(after);
            }
            if (unlocks[course].length) yield frame(19, `Finishing ${course} unlocks a prerequisite of ${unlocks[course].join(', ')}.${unlocks[course].some((after) => next.includes(after) && waitingOn[after] === 0) ? ` ${unlocks[course].filter((after) => next.includes(after)).join(', ')} now wait${unlocks[course].filter((after) => next.includes(after)).length === 1 ? 's' : ''} on nothing: next semester.` : ''}`, course);
        }
        current = next;
        next = [];
        yield frame(23, current.length ? `Semester ${plan.length + 1} will take ${current.join(', ')}.` : 'Nothing is ready for another semester.');
    }
    const taken = Object.keys(semester).length;
    yield frame(25, taken === ids.length ? `${plan.length} semesters: the length of the longest prerequisite chain. Nothing could be done sooner, because every course waited only as long as its slowest prerequisite.` : `Only ${taken} of ${ids.length} courses could be taken: the rest sit on a cycle, so there's no plan.`);
}

function* topoDfs(graph) {
    const neighbours = neighboursOf(graph);
    const finished = [];
    const edges = {};
    const makeFrame = (line, message, { stack = [], visited = new Set(), from } = {}) => {
        if (from) edges[edgeKey(from[0], from[1], true)] = 'tree';
        return {
            states: Object.fromEntries(graph.nodes.map((node) => [node.id, node.id === stack.at(-1) ? 'current' : stack.includes(node.id) ? 'frontier' : finished.includes(node.id) ? 'done' : visited.has(node.id) ? 'frontier' : 'idle'])),
            edges: { ...edges },
            labels: Object.fromEntries(finished.map((id, index) => [id, `f${index + 1}`])),
            side: [{ title: 'call stack (top last)', items: [...stack] }, { title: 'finished', items: [...finished] }],
            line,
            message,
        };
    };
    yield makeFrame(9, 'Run DFS from each unvisited node in turn, and note the order in which nodes finish.');
    yield* finishingPass(graph, neighbours, finished, makeFrame, { visit: 5, finish: 7 });
    const order = [...finished].reverse();
    yield { ...makeFrame(10, `Reverse the finishing order: ${order.join(' → ')}. Every edge points from earlier to later, because a node always finishes after everything it points to.`), side: [{ title: 'topological order', items: order }] };
}

function* scc(graph) {
    const neighbours = neighboursOf(graph);
    const reversed = Object.fromEntries(graph.nodes.map((node) => [node.id, []]));
    graph.edges.forEach(([a, b]) => reversed[b].push(a));
    Object.values(reversed).forEach((list) => list.sort());
    const finished = [];
    const component = {};
    const components = [];
    const edges = {};
    const firstFrame = (line, message, { stack = [], visited = new Set(), from } = {}) => {
        if (from) edges[edgeKey(from[0], from[1], true)] = 'tree';
        return {
            states: Object.fromEntries(graph.nodes.map((node) => [node.id, node.id === stack.at(-1) ? 'current' : stack.includes(node.id) ? 'frontier' : finished.includes(node.id) ? 'done' : visited.has(node.id) ? 'frontier' : 'idle'])),
            edges: { ...edges },
            labels: Object.fromEntries(finished.map((id, index) => [id, `f${index + 1}`])),
            side: [{ title: 'pass 1: call stack', items: [...stack] }, { title: 'finished', items: [...finished] }],
            line,
            message,
        };
    };
    yield firstFrame(9, 'Pass 1: DFS over the whole graph, recording the order in which nodes finish.');
    yield* finishingPass(graph, neighbours, finished, firstFrame, { visit: 5, finish: 7 });
    const starts = [...finished].reverse();
    Object.keys(edges).forEach((key) => delete edges[key]);
    const secondFrame = (line, message, current) => ({
        states: Object.fromEntries(graph.nodes.map((node) => [node.id, node.id === current ? 'current' : component[node.id] === components.length && component[node.id] !== undefined ? 'frontier' : component[node.id] !== undefined ? 'done' : 'idle'])),
        edges: { ...edges },
        labels: Object.fromEntries(graph.nodes.map((node) => [node.id, component[node.id] !== undefined ? `C${component[node.id]}` : `f${finished.indexOf(node.id) + 1}`])),
        side: [{ title: 'pass 2 starts (latest finish first)', items: starts.filter((id) => component[id] === undefined) }, { title: 'components', items: components.map((members, index) => `C${index + 1}: ${members.join(' ')}`) }],
        line,
        message,
    });
    yield secondFrame(14, 'Pass 2 walks the reversed graph (every arrow flipped), starting from the node that finished last. Following arrows backwards can\'t leave a component without reaching one that\'s already been claimed.');
    function* claim(node, from) {
        component[node] = components.length;
        components.at(-1).push(node);
        if (from) edges[edgeKey(node, from, true)] = 'used';
        yield secondFrame(17, from ? `${node} reaches back to ${from} (${node}→${from} in the original graph), so it joins C${components.length}.` : `${node} starts C${components.length}.`, node);
        for (const next of reversed[node]) {
            if (component[next] === undefined) yield* claim(next, node);
        }
    }
    for (const node of starts) {
        if (component[node] !== undefined) continue;
        components.push([]);
        yield* claim(node, null);
        yield secondFrame(22, `C${components.length} is complete: {${components.at(-1).join(', ')}}. Every node in it can reach every other.`);
    }
    yield secondFrame(24, `${components.length} strongly connected components, found with two DFS passes: O(V + E).`);
}

// Edmonds–Karp on an adjacency matrix: BFS finds the shortest augmenting path in the residual graph.
// Antiparallel edges (both u→v and v→u) aren't supported in a picture, because flow labels would be ambiguous.
function* maxFlow(graph, source, sink) {
    const ids = graph.nodes.map((node) => node.id);
    const index = Object.fromEntries(ids.map((id, at) => [id, at]));
    const n = ids.length;
    const capacity = Array.from({ length: n }, () => Array(n).fill(0));
    graph.edges.forEach(([a, b, c]) => { capacity[index[a]][index[b]] += c; });
    const residual = capacity.map((row) => [...row]);
    let total = 0;
    let rounds = 0;
    const flowLabels = () => Object.fromEntries(graph.edges.map(([a, b, c]) => [edgeKey(a, b, true), `${Math.max(0, c - residual[index[a]][index[b]])}/${c}`]));
    const frame = (line, message, { path = [], states = {} } = {}) => {
        const edges = {};
        graph.edges.forEach(([a, b]) => { if (residual[index[a]][index[b]] === 0) edges[edgeKey(a, b, true)] = 'tree'; });
        path.forEach(([u, v]) => {
            if (capacity[u][v] > 0) edges[edgeKey(ids[u], ids[v], true)] = 'used';
            else edges[edgeKey(ids[v], ids[u], true)] = 'rejected';
        });
        return {
            states: { ...Object.fromEntries(ids.map((id) => [id, 'idle'])), [source]: 'current', [sink]: 'current', ...states },
            edges,
            edgeLabels: flowLabels(),
            labels: {},
            side: [{ title: 'total flow', items: [String(total)] }, { title: 'augmenting paths', items: [String(rounds)] }],
            line,
            message,
        };
    };
    yield frame(3, `Every edge shows flow/capacity, starting at 0. Find a path from ${source} to ${sink} with room left, push as much as it can take, and repeat.`);
    const s = index[source];
    const t = index[sink];
    for (;;) {
        const parent = Array(n).fill(-1);
        parent[s] = s;
        const queue = [s];
        for (let head = 0; head < queue.length && parent[t] === -1; head += 1) {
            const u = queue[head];
            for (let v = 0; v < n; v += 1) {
                if (parent[v] === -1 && residual[u][v] > 0) {
                    parent[v] = u;
                    queue.push(v);
                }
            }
        }
        if (parent[t] === -1) {
            const sourceSide = new Set(queue.map((at) => ids[at]));
            const cut = graph.edges.filter(([a, b]) => sourceSide.has(a) && !sourceSide.has(b));
            const states = Object.fromEntries(ids.map((id) => [id, sourceSide.has(id) ? 'done' : 'idle']));
            const result = frame(15, `No path with room is left, so the flow is maximal: ${total}. The green nodes are still reachable from ${source}; the edges leaving them (${cut.map(([a, b]) => `${a}→${b}`).join(', ')}) are full and add up to ${cut.reduce((sum, edge) => sum + edge[2], 0)}: a minimum cut equal to the maximum flow.`, { states });
            cut.forEach(([a, b]) => { result.edges[edgeKey(a, b, true)] = 'used'; });
            yield result;
            return;
        }
        const path = [];
        for (let v = t; v !== s; v = parent[v]) path.unshift([parent[v], v]);
        const bottleneck = Math.min(...path.map(([u, v]) => residual[u][v]));
        const backwards = path.filter(([u, v]) => capacity[u][v] === 0);
        const route = [ids[s], ...path.map(([, v]) => ids[v])].join('→');
        yield frame(18, `BFS finds the shortest path with room: ${route}. Its tightest edge allows ${bottleneck}.${backwards.length ? ` It uses ${backwards.map(([u, v]) => `${ids[v]}→${ids[u]}`).join(', ')} backwards (dashed): that cancels flow sent earlier, rerouting it.` : ''}`, { path, states: Object.fromEntries(path.map(([, v]) => [ids[v], 'frontier'])) });
        path.forEach(([u, v]) => {
            residual[u][v] -= bottleneck;
            residual[v][u] += bottleneck;
        });
        total += bottleneck;
        rounds += 1;
        yield frame(25, `Push ${bottleneck} along it. Total flow ${total}. Full edges are green.`, { path });
    }
}

const PROGRAMS = {
    bfs: { title: 'Breadth-first search', graph: 'small', code: CODE.bfs, run: (graph, start) => bfs(graph, start ?? graph.nodes[0].id) },
    dfs: { title: 'Depth-first search', graph: 'small', code: CODE.dfs, run: (graph, start) => dfs(graph, start ?? graph.nodes[0].id) },
    dijkstra: { title: 'Dijkstra’s shortest paths', graph: 'weighted', code: CODE.dijkstra, run: (graph, start) => dijkstra(graph, start ?? graph.nodes[0].id) },
    topo: { title: 'Topological sort with Kahn’s algorithm', graph: 'dag', code: CODE.topo, run: (graph) => topo(graph) },
    kruskal: { title: 'Kruskal’s minimum spanning tree', graph: 'weighted', code: CODE.kruskal, run: (graph) => kruskal(graph) },
    topoWaves: { title: 'Kahn’s algorithm in waves: the fewest semesters', graph: 'dag', code: CODE.topoWaves, run: (graph) => topoWaves(graph) },
    topoDfs: { title: 'Topological sort with DFS finishing order', graph: 'dag', code: CODE.topoDfs, run: (graph) => topoDfs(graph) },
    scc: { title: 'Strongly connected components (Kosaraju)', graph: 'scc', code: CODE.scc, run: (graph) => scc(graph) },
    prim: { title: 'Prim’s minimum spanning tree', graph: 'weighted', code: CODE.prim, run: (graph, start) => prim(graph, start ?? graph.nodes[0].id) },
    maxFlow: { title: 'Maximum flow with Edmonds–Karp', graph: 'flow', code: CODE.maxFlow, run: (graph, start, end) => maxFlow(graph, start ?? graph.nodes[0].id, end ?? graph.nodes.at(-1).id) },
    bellmanFord: { title: 'Bellman–Ford shortest paths', graph: 'negative', code: CODE.bellmanFord, run: (graph, start) => bellmanFord(graph, start ?? graph.nodes[0].id) },
};

export const GRAPH_PROGRAMS = Object.keys(PROGRAMS);

export const graphProgram = (name) => {
    const program = PROGRAMS[name];
    if (!program) throw new Error(`Unknown graph program "${name}"`);
    return program;
};

export const graphFrames = (name, { graph, start, end } = {}) => {
    const program = graphProgram(name);
    const resolved = typeof graph === 'object' && graph !== null ? graph : GRAPHS[graph ?? program.graph];
    return { graph: resolved, frames: [...program.run(resolved, start, end)] };
};

// ── Grids ──────────────────────────────────────────────────────────────────────────────────────

export const GRID_CODE = CODE.bfs.replace('func bfs(from start: Node, _ graph: [Node: [Node]]) -> [Node] {', 'func bfs(from start: Cell, in grid: Grid) -> [Cell] {');

export const gridFrames = ({ rows = ['S..#....', '.#.#.##.', '.#...#..', '...#...G'] } = {}) => {
    const grid = rows.map((row) => [...row]);
    const height = grid.length;
    const width = grid[0].length;
    let start = null;
    let goal = null;
    grid.forEach((row, r) => row.forEach((cell, c) => {
        if (cell === 'S') start = [r, c];
        if (cell === 'G') goal = [r, c];
    }));
    const distance = grid.map((row) => row.map(() => null));
    const previous = {};
    const queue = [start];
    distance[start[0]][start[1]] = 0;
    const frames = [];
    const snapshot = (message, current, path = []) => frames.push({
        grid,
        distance: distance.map((row) => [...row]),
        current,
        queue: queue.slice(head).map(([r, c]) => `${r},${c}`),
        path: path.map(([r, c]) => `${r},${c}`),
        message,
    });
    let head = 0;
    snapshot('Start at S with distance 0. BFS spreads out one step at a time, like a ripple.');
    while (head < queue.length) {
        const [r, c] = queue[head];
        head += 1;
        if (r === goal[0] && c === goal[1]) {
            const path = [];
            let key = `${r},${c}`;
            while (key) {
                path.unshift(key.split(',').map(Number));
                key = previous[key];
            }
            snapshot(`Reached G in ${distance[r][c]} steps. Following each cell back to where it was reached from gives a shortest path.`, [r, c], path);
            return frames;
        }
        const added = [];
        for (const [dr, dc] of [[-1, 0], [1, 0], [0, -1], [0, 1]]) {
            const nr = r + dr;
            const nc = c + dc;
            if (nr < 0 || nr >= height || nc < 0 || nc >= width || grid[nr][nc] === '#' || distance[nr][nc] !== null) continue;
            distance[nr][nc] = distance[r][c] + 1;
            previous[`${nr},${nc}`] = `${r},${c}`;
            queue.push([nr, nc]);
            added.push(`${nr},${nc}`);
        }
        snapshot(`Cell (${r}, ${c}) at distance ${distance[r][c]}: ${added.length ? `${added.length} new neighbour${added.length === 1 ? '' : 's'} at distance ${distance[r][c] + 1}` : 'no new neighbours'}.`, [r, c]);
    }
    snapshot('The queue ran dry before reaching G: there is no path.');
    return frames;
};

// A* on a grid, matching the sp-a-star lesson: unit steps in the order right, down, left, up, a heap ordered by
// (f, h, row, col), stale entries skipped, and the search stops when the goal comes out of the heap.
// `algorithm: 'dijkstra'` runs the same code with h = 0, which is Dijkstra.
const astarCode = (heuristic) => `func aStar(_ grid: [[Character]], from start: Cell, to goal: Cell) -> Int? {
    ${heuristic}
    var best: [Cell: Int] = [start: 0]
    var open = Heap<(f: Int, h: Int, cell: Cell)>(areInIncreasingOrder: {
        ($0.f, $0.h, $0.cell.row, $0.cell.col) < ($1.f, $1.h, $1.cell.row, $1.cell.col)
    })
    open.insert((h(start), h(start), start))
    while let entry = open.pop() {
        let g = entry.f - entry.h
        if g > best[entry.cell]! { continue }               // a stale entry
        if entry.cell == goal { return g }
        for next in neighbours(of: entry.cell, in: grid) {  // right, down, left, up
            if g + 1 < best[next, default: .max] {
                best[next] = g + 1
                open.insert((g + 1 + h(next), h(next), next))
            }
        }
    }
    return nil
}`;

export const ASTAR_CODE = {
    astar: astarCode('let h = { (cell: Cell) in abs(cell.row - goal.row) + abs(cell.col - goal.col) }'),
    dijkstra: astarCode('let h = { (_: Cell) in 0 }                          // no estimate: Dijkstra'),
};

export const astarFrames = ({ rows = ['S....#......', '.....#......', '.....#......', '.....#....#.', '.....#....#G', '..........#.'], algorithm = 'astar' } = {}) => {
    const grid = rows.map((row) => [...row]);
    const height = grid.length;
    const width = grid[0].length;
    let start = null;
    let goal = null;
    grid.forEach((row, r) => row.forEach((cell, c) => {
        if (cell === 'S') start = [r, c];
        if (cell === 'G') goal = [r, c];
    }));
    const estimate = algorithm === 'dijkstra' ? () => 0 : (r, c) => Math.abs(r - goal[0]) + Math.abs(c - goal[1]);
    const best = grid.map((row) => row.map(() => null));
    const expanded = grid.map((row) => row.map(() => false));
    const previous = {};
    const open = [];
    const order = (a, b) => a.f - b.f || a.h - b.h || a.r - b.r || a.c - b.c;
    const frames = [];
    let count = 0;
    const snapshot = (line, message, current, path = []) => frames.push({
        grid,
        algorithm,
        g: best.map((row) => [...row]),
        h: best.map((row, r) => row.map((g, c) => (g === null ? null : estimate(r, c)))),
        expanded: expanded.map((row) => [...row]),
        open: [...open].sort(order).map(({ r, c, f }) => ({ key: `${r},${c}`, f })),
        current,
        path: path.map(([r, c]) => `${r},${c}`),
        count,
        line,
        message,
    });
    const push = (r, c, g) => {
        best[r][c] = g;
        const h = estimate(r, c);
        open.push({ r, c, h, f: g + h });
    };
    push(start[0], start[1], 0);
    snapshot(7, algorithm === 'dijkstra'
        ? 'Start at S with g = 0. With h = 0 everywhere, f = g: the heap hands out the closest cell, like a ripple.'
        : `Start at S: g = 0, h = ${estimate(...start)} (the Manhattan distance, as if there were no walls), so f = ${estimate(...start)}.`);
    while (open.length) {
        open.sort(order);
        const { r, c, h, f } = open.shift();
        const g = f - h;
        if (g > best[r][c]) {
            snapshot(10, `(${r}, ${c}) with g = ${g} is stale: a cheaper path to it (g = ${best[r][c]}) was found after this entry went in. Skip it.`, [r, c]);
            continue;
        }
        expanded[r][c] = true;
        count += 1;
        const tied = open.some((entry) => entry.f === f);
        if (r === goal[0] && c === goal[1]) {
            const path = [];
            let key = `${r},${c}`;
            while (key) {
                path.unshift(key.split(',').map(Number));
                key = previous[key];
            }
            const openCells = grid.flat().filter((cell) => cell !== '#').length;
            snapshot(11, `G comes out of the heap with g = ${g}: that's the shortest path. ${algorithm === 'dijkstra' ? 'Dijkstra' : 'A*'} expanded ${count} of the ${openCells} open cells. Following each cell back to the one that improved it gives the route.`, [r, c], path);
            return frames;
        }
        const added = [];
        for (const [dr, dc] of [[0, 1], [1, 0], [0, -1], [-1, 0]]) {
            const nr = r + dr;
            const nc = c + dc;
            if (nr < 0 || nr >= height || nc < 0 || nc >= width || grid[nr][nc] === '#') continue;
            if (best[nr][nc] !== null && g + 1 >= best[nr][nc]) continue;
            push(nr, nc, g + 1);
            previous[`${nr},${nc}`] = `${r},${c}`;
            added.push(`(${nr}, ${nc}) f ${g + 1 + estimate(nr, nc)}`);
        }
        const popped = algorithm === 'dijkstra' ? `g = ${g}, the smallest in the heap` : `f = ${g} + ${h} = ${f}, the smallest f in the heap${tied ? ' (ties go to the smaller h)' : ''}`;
        snapshot(added.length ? 15 : 12, `Expand (${r}, ${c}): ${popped}. ${added.length ? `Add ${added.join(', ')}.` : 'No neighbour gets cheaper.'}`, [r, c]);
    }
    snapshot(19, 'The heap ran dry before G came out: there is no path.');
    return frames;
};
