// Generated from src/dsa/design/content/lessons/sd-refactoring/sd-refactoring-replace-conditional.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

protocol FeedContent {
    var title: String { get }
    var icon: String { get }
    var subtitle: String { get }
    var canDownload: Bool { get }
}

extension FeedContent {
    // The usual answer, as a default for a requirement; media types override it
    var canDownload: Bool { false }
}

struct Article: FeedContent {
    let title: String
    let readingMinutes: Int
    var icon: String { "doc.text" }
    var subtitle: String { "\(readingMinutes) min read" }
}

struct Video: FeedContent {
    let title: String
    let minutes: Int
    var icon: String { "play.rectangle" }
    var subtitle: String { "\(minutes) min" }
    var canDownload: Bool { true }
}

struct Podcast: FeedContent {
    let title: String
    let minutes: Int
    let episode: Int
    var icon: String { "waveform" }
    var subtitle: String { "Episode \(episode) · \(minutes) min" }
    var canDownload: Bool { true }
}

// The one switch left: at the boundary, where the server's string becomes a type
func content(kind: String, title: String, minutes: Int, episode: Int? = nil) -> (any FeedContent)? {
    switch kind {
    case "article":
        return Article(title: title, readingMinutes: minutes)
    case "video":
        return Video(title: title, minutes: minutes)
    case "podcast":
        guard let episode else { return nil }
        return Podcast(title: title, minutes: minutes, episode: episode)
    default:
        return nil
    }
}

let feed = [
    content(kind: "article", title: "Rain returns", minutes: 4),
    content(kind: "podcast", title: "Morning brief", minutes: 22, episode: 118),
    content(kind: "video", title: "Ferry rescue", minutes: 3),
    content(kind: "livestream", title: "Election night", minutes: 0),
].compactMap { $0 }

// The feed never asks what kind an item is
for item in feed {
    print("[\(item.icon)] \(item.title): \(item.subtitle)\(item.canDownload ? " ↓" : "")")
}
