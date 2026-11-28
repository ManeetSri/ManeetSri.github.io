// Generated from src/dsa/content/lessons/swift-generics/swift-collection-subscripts.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Playlist: Collection {
    private var songs: [String]
    init(_ songs: [String]) { self.songs = songs }
    var startIndex: Int { 0 }
    var endIndex: Int { songs.count }
    func index(after i: Int) -> Int { i + 1 }
    subscript(position: Int) -> String { songs[position] }
}

extension Playlist: BidirectionalCollection, RandomAccessCollection {
    func index(before i: Int) -> Int {
        i - 1
    }
}

let mix = Playlist(["Blue", "Hey Jude", "Imagine"])
print(mix.last ?? "")
print(Array(mix.reversed()))
print(mix.indices)
