// Reference solution: Train seat bookings. Keep the free seats of every stretch in a lazy segment
// tree that supports "add to a range" and "minimum of a range". A request for `people` seats from
// station a to station b needs stretches a...b - 1; it fits exactly when the minimum free count there
// is at least `people`, and then it adds -people to that range. Pending additions on whole blocks
// make both operations O(log n). O(n + q log n) time, O(n) space.

public enum TrainSeatBookings {
    public static func process(seats: [Int], requests: [[Int]]) -> [Bool] {
        var free = FreeSeats(seats)
        return requests.map { request in
            let first = request[0], last = request[1] - 1, people = request[2]
            guard free.minimum(first, last) >= people else { return false }
            free.add(-people, first, last)
            return true
        }
    }

    /// Range add and range minimum, with lazy tags. Recursive, nodes numbered from 1, closed ranges.
    private struct FreeSeats {
        private var minimums: [Int]
        private var pending: [Int]               // added to a whole node, not yet to its children
        private let count: Int

        init(_ values: [Int]) {
            count = values.count
            minimums = Array(repeating: 0, count: 4 * values.count)
            pending = Array(repeating: 0, count: 4 * values.count)
            build(values, 1, 0, count - 1)
        }

        mutating func minimum(_ left: Int, _ right: Int) -> Int {
            minimum(left, right, 1, 0, count - 1)
        }

        mutating func add(_ delta: Int, _ left: Int, _ right: Int) {
            add(delta, left, right, 1, 0, count - 1)
        }

        private mutating func build(_ values: [Int], _ node: Int, _ low: Int, _ high: Int) {
            if low == high {
                minimums[node] = values[low]
                return
            }
            let mid = (low + high) / 2
            build(values, 2 * node, low, mid)
            build(values, 2 * node + 1, mid + 1, high)
            minimums[node] = min(minimums[2 * node], minimums[2 * node + 1])
        }

        private mutating func apply(_ delta: Int, _ node: Int) {
            minimums[node] += delta              // every stretch below drops by the same amount
            pending[node] += delta
        }

        private mutating func push(_ node: Int) {
            if pending[node] == 0 { return }
            apply(pending[node], 2 * node)
            apply(pending[node], 2 * node + 1)
            pending[node] = 0
        }

        private mutating func minimum(_ left: Int, _ right: Int, _ node: Int, _ low: Int, _ high: Int) -> Int {
            if right < low || high < left { return Int.max }
            if left <= low && high <= right { return minimums[node] }
            push(node)
            let mid = (low + high) / 2
            return min(minimum(left, right, 2 * node, low, mid), minimum(left, right, 2 * node + 1, mid + 1, high))
        }

        private mutating func add(_ delta: Int, _ left: Int, _ right: Int, _ node: Int, _ low: Int, _ high: Int) {
            if right < low || high < left { return }
            if left <= low && high <= right {
                apply(delta, node)
                return
            }
            push(node)
            let mid = (low + high) / 2
            add(delta, left, right, 2 * node, low, mid)
            add(delta, left, right, 2 * node + 1, mid + 1, high)
            minimums[node] = min(minimums[2 * node], minimums[2 * node + 1])
        }
    }
}
