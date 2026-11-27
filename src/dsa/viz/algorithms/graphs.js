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
    kruskal: `func minimumSpanningTree(_ nodeCount: Int, _ edges: [(Int, Int, Int)]) -> [(Int, Int, Int)] {
    var sets = UnionFind(nodeCount)
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

const PROGRAMS = {
    bfs: { title: 'Breadth-first search', graph: 'small', code: CODE.bfs, run: (graph, start) => bfs(graph, start ?? graph.nodes[0].id) },
    dfs: { title: 'Depth-first search', graph: 'small', code: CODE.dfs, run: (graph, start) => dfs(graph, start ?? graph.nodes[0].id) },
    dijkstra: { title: 'Dijkstra’s shortest paths', graph: 'weighted', code: CODE.dijkstra, run: (graph, start) => dijkstra(graph, start ?? graph.nodes[0].id) },
    topo: { title: 'Topological sort with Kahn’s algorithm', graph: 'dag', code: CODE.topo, run: (graph) => topo(graph) },
    kruskal: { title: 'Kruskal’s minimum spanning tree', graph: 'weighted', code: CODE.kruskal, run: (graph) => kruskal(graph) },
};

export const GRAPH_PROGRAMS = Object.keys(PROGRAMS);

export const graphProgram = (name) => {
    const program = PROGRAMS[name];
    if (!program) throw new Error(`Unknown graph program "${name}"`);
    return program;
};

export const graphFrames = (name, { graph, start } = {}) => {
    const program = graphProgram(name);
    const resolved = typeof graph === 'object' && graph !== null ? graph : GRAPHS[graph ?? program.graph];
    return { graph: resolved, frames: [...program.run(resolved, start)] };
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
