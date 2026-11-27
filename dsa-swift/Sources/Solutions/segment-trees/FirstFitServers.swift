// Reference solution: First server with enough room. An iterative segment tree of maximums over the
// servers' free memory. For each job, if the root's maximum is too small, reject it; otherwise walk down,
// going left whenever the left block's maximum fits, to the first fitting server. Subtract there and fix
// the maximums on the way up. O(n) to build, O(log n) per job.

public enum FirstFitServers {
    public static func place(_ jobs: [Int], on capacities: [Int]) -> [Int] {
        var size = 1
        while size < capacities.count {
            size *= 2
        }
        var tree = Array(repeating: -1, count: 2 * size)    // unused leaves can't fit any job
        for (i, free) in capacities.enumerated() {
            tree[size + i] = free
        }
        for node in stride(from: size - 1, through: 1, by: -1) {
            tree[node] = max(tree[2 * node], tree[2 * node + 1])
        }

        var placements: [Int] = []
        placements.reserveCapacity(jobs.count)
        for job in jobs {
            guard !capacities.isEmpty, tree[1] >= job else {
                placements.append(-1)
                continue
            }
            var node = 1
            while node < size {
                node = tree[2 * node] >= job ? 2 * node : 2 * node + 1
            }
            placements.append(node - size)
            tree[node] -= job
            node /= 2
            while node >= 1 {
                tree[node] = max(tree[2 * node], tree[2 * node + 1])
                node /= 2
            }
        }
        return placements
    }
}
