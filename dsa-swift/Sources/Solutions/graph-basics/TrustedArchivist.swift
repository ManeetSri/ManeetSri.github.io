// Reference solution: The trusted archivist. Read each trust pair [a, b] as a directed edge a → b.
// The archivist is the vertex with in-degree n - 1 (everyone else trusts them) and out-degree 0
// (they trust nobody). One pass over the pairs counts both degrees, and one pass over the people
// checks them: O(n + t) time for n people and t pairs, O(n) extra space. No adjacency list needed.

public enum TrustedArchivist {
    public static func find(peopleCount: Int, trusts: [[Int]]) -> Int {
        var trustedBy = Array(repeating: 0, count: peopleCount)      // in-degree
        var trustsOthers = Array(repeating: 0, count: peopleCount)   // out-degree
        for pair in trusts {
            trustsOthers[pair[0]] += 1
            trustedBy[pair[1]] += 1
        }
        for person in 0..<peopleCount where trustedBy[person] == peopleCount - 1 && trustsOthers[person] == 0 {
            return person
        }
        return -1
    }
}
