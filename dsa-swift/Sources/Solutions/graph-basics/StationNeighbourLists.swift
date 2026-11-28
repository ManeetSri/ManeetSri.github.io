// Reference solution: Station neighbour lists. Build an adjacency list with one array per station,
// shifting the 1-based station numbers down by one for the index. Each undirected link is recorded
// at both ends. Sorting each list puts repeated links side by side, so one pass drops them.
// O(n + m log m) time for n stations and m links (the sorts dominate), O(n + m) space.

public enum StationNeighbourLists {
    public static func build(stationCount: Int, links: [[Int]]) -> [[Int]] {
        var lists = Array(repeating: [Int](), count: stationCount)
        for link in links {
            let a = link[0]
            let b = link[1]
            lists[a - 1].append(b)          // station a lives at index a - 1
            lists[b - 1].append(a)          // undirected: both ends know about the link
        }
        return lists.map { list in
            var unique: [Int] = []
            for station in list.sorted() where station != unique.last {
                unique.append(station)
            }
            return unique
        }
    }
}
