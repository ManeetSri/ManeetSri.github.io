// Generated from src/dsa/content/lessons/swift-optionals/swift-optional-chaining.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var playlists = ["chill": ["Song A"], "gym": ["Song B", "Song C"]]

playlists["chill"]?.append("Song D")
playlists["party"]?.append("Song E")

print(playlists["chill"] ?? [])
print(playlists["party"] ?? [])
