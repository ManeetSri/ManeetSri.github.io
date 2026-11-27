// Generated from src/dsa/content/lessons/swift-types/swift-structs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Song {
    var title: String
    var artist: String
    var plays = 0
}

let fresh = Song(title: "Blue", artist: "Joni")
let favourite = Song(title: "Hey Jude", artist: "The Beatles", plays: 120)
print(fresh.plays)
print(favourite.plays)
