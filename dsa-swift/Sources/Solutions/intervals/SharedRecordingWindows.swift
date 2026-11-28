// Reference solution: Shared recording windows. Two pointers, one per list. Record the overlap of the
// two current windows (later start to earlier end, kept if start <= end because windows are closed),
// then move on from whichever window ends first: nothing later in the other list can reach back to it.
// O(m + n) time, O(1) extra space besides the result.

public enum SharedRecordingWindows {
    public static func sharedWindows(_ first: [[Int]], _ second: [[Int]]) -> [[Int]] {
        var result: [[Int]] = []
        var i = 0
        var j = 0
        while i < first.count && j < second.count {
            let start = max(first[i][0], second[j][0])
            let end = min(first[i][1], second[j][1])
            if start <= end {
                result.append([start, end])
            }
            if first[i][1] < second[j][1] {
                i += 1
            } else {
                j += 1
            }
        }
        return result
    }
}
