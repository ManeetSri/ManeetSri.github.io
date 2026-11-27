// Generated from src/dsa/content/lessons/swift-generics/swift-collection-subscripts.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Playlist: Collection {
    private var songs: [String]

    init(_ songs: [String]) {
        self.songs = songs
    }

    var startIndex: Int { 0 }
    var endIndex: Int { songs.count }

    func index(after i: Int) -> Int {
        i + 1
    }

    subscript(position: Int) -> String {
        songs[position]
    }
}

let mix = Playlist(["Blue", "Hey Jude", "Imagine", "Yesterday"])
print(mix.count, mix.isEmpty)
print(mix[2])
print(mix.first ?? "")
print(mix.firstIndex(of: "Imagine") ?? -1)
print(mix.map { $0.count })
print(Array(mix.dropFirst(2)))
print(mix.sorted(by: >))
