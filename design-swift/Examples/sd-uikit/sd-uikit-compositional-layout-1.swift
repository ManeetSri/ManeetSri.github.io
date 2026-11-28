// Generated from src/dsa/design/content/lessons/sd-uikit/sd-uikit-compositional-layout.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

enum SectionKind: String {
    case carousel, grid, list
}

struct FeedSection: Decodable {
    let id: String
    let title: String
    let kind: SectionKind? // nil when this version of the app doesn't know the layout

    private enum CodingKeys: String, CodingKey {
        case id, title, kind
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        kind = SectionKind(rawValue: try container.decode(String.self, forKey: .kind))
    }
}

let response = Data("""
[
    { "id": "hero", "kind": "carousel", "title": "Featured" },
    { "id": "cats", "kind": "grid", "title": "Categories" },
    { "id": "live", "kind": "liveScores", "title": "Live now" },
    { "id": "recent", "kind": "list", "title": "Recently viewed" }
]
""".utf8)

let sections = try JSONDecoder().decode([FeedSection].self, from: response)
for section in sections {
    if let kind = section.kind {
        print("\(section.title): \(kind) section")
    } else {
        print("\(section.title): skipped, unknown kind")
    }
}
