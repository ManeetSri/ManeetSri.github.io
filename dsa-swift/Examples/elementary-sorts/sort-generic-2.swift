// Generated from src/dsa/content/lessons/elementary-sorts/sort-generic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func insertionSort<T>(_ items: inout [T], by areInIncreasingOrder: (T, T) -> Bool) {
    guard items.count > 1 else { return }
    for i in 1..<items.count {
        let key = items[i]
        var gap = i
        while gap > 0 && areInIncreasingOrder(key, items[gap - 1]) {
            items[gap] = items[gap - 1]
            gap -= 1
        }
        items[gap] = key
    }
}

func insertionSort<T: Comparable>(_ items: inout [T]) {
    insertionSort(&items, by: <)
}

struct Song {
    let title: String
    let plays: Int
}

var songs = [
    Song(title: "Blue", plays: 40),
    Song(title: "Rain", plays: 95),
    Song(title: "Dawn", plays: 40),
]
insertionSort(&songs) { $0.plays > $1.plays }        // most played first
print(songs.map(\.title))

var scores = [3, 9, 1]
insertionSort(&scores)
print(scores)
