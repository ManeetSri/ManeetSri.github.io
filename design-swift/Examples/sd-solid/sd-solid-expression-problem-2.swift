// Generated from src/dsa/design/content/lessons/sd-solid/sd-solid-expression-problem.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

enum Card: Decodable {
    case text(String)
    case image(url: String)
    case unsupported(type: String)

    private enum Key: String, CodingKey { case type, body, url }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "text": self = .text(try container.decode(String.self, forKey: .body))
        case "image": self = .image(url: try container.decode(String.self, forKey: .url))
        default: self = .unsupported(type: type)
        }
    }
}

let json = Data(#"[{"type": "text", "body": "Hello"}, {"type": "poll", "question": "Tea?"}, {"type": "image", "url": "a.jpg"}]"#.utf8)
let cards = try JSONDecoder().decode([Card].self, from: json)
for card in cards {
    switch card {
    case .text(let body): print("text:", body)
    case .image(let url): print("image:", url)
    case .unsupported(let type): print("skipped a \(type) card")
    }
}
