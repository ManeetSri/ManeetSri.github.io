// Reference solution: Record breakers. One pass with the invariant "best is the largest score before i".
// O(n) time, O(1) extra space apart from the answer.

public enum RecordBreakers {
    public static func recordIndices(in scores: [Int]) -> [Int] {
        guard var best = scores.first else { return [] }
        var records = [0]
        for i in scores.indices.dropFirst() where scores[i] > best {
            records.append(i)
            best = scores[i]
        }
        return records
    }
}
