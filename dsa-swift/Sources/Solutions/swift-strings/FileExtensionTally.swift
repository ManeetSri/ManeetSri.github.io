// Reference solution: Count the file extensions. Slice after the last dot (an O(1) Substring),
// and copy it into a String only when storing it as a dictionary key.
// O(L) time for L characters in all, O(E) space for the distinct extensions.

public enum FileExtensionTally {
    public static func tally(_ fileNames: [String]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for name in fileNames {
            guard let dot = name.lastIndex(of: "."), dot != name.startIndex else {
                continue
            }
            let ext = name[name.index(after: dot)...]
            if !ext.isEmpty {
                counts[String(ext), default: 0] += 1
            }
        }
        return counts
    }
}
