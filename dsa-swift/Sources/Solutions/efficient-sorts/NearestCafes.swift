// Reference solution: The nearest cafés. Quickselect on the cafés' indexes, ordered by squared
// distance (x * x + y * y orders cafés exactly as the real distance does, with no square roots).
// Partition three ways around a random pivot. Once position k falls inside or at the edge of the
// pivot's equal block, the first k indexes are k nearest cafés. O(n) expected time, O(n) space for
// the indexes and distances.

public enum NearestCafes {
    public static func nearest(_ cafes: [(x: Int, y: Int)], count k: Int) -> [Int] {
        let distance = cafes.map { $0.x * $0.x + $0.y * $0.y }
        var order = Array(cafes.indices)
        var low = 0
        var high = order.count
        while low < high {
            let pivot = distance[order[Int.random(in: low..<high)]]
            var less = low                               // low..<less: nearer than the pivot
            var scan = low                               // less..<scan: the same distance
            var greater = high                           // greater..<high: further away
            while scan < greater {
                let d = distance[order[scan]]
                if d < pivot {
                    order.swapAt(less, scan)
                    less += 1
                    scan += 1
                } else if d > pivot {
                    greater -= 1
                    order.swapAt(scan, greater)
                } else {
                    scan += 1
                }
            }
            if k < less {
                high = less                              // the cut is among the nearer cafés
            } else if k > greater {
                low = greater                            // the cut is among the further cafés
            } else {
                break                                    // order[..<k] is k nearest cafés
            }
        }
        return Array(order[..<k])
    }
}
