// Reference solution: Rebuild the queue by height. Sort by height descending, and equal heights by k
// ascending, then insert each person at index k. Everyone already placed is at least as tall, so all of
// them count and index k gives exactly k in front; people placed later are shorter, so they never change
// a taller person's count. O(n log n) for the sort plus O(n²) for the inserts, O(n) space.

public enum HeightQueueRebuild {
    public static func rebuild(_ people: [[Int]]) -> [[Int]] {
        let order = people.sorted { $0[0] != $1[0] ? $0[0] > $1[0] : $0[1] < $1[1] }
        var queue: [[Int]] = []
        queue.reserveCapacity(people.count)
        for person in order {
            queue.insert(person, at: person[1])
        }
        return queue
    }
}
