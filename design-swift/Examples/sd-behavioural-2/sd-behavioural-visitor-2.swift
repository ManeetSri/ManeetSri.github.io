// Generated from src/dsa/design/content/lessons/sd-behavioural-2/sd-behavioural-visitor.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

indirect enum Component {
    case text(String)
    case image(url: String, alt: String)
    case button(title: String, deepLink: String)
    case stack([Component])
    case unsupported(type: String)   // a component this version of the app doesn't know
}

// Each operation is one function with one exhaustive switch
extension Component {
    var imagesToPrefetch: [String] {
        switch self {
        case .image(let url, _): [url]
        case .stack(let children): children.flatMap(\.imagesToPrefetch)
        case .text, .button, .unsupported: []
        }
    }

    var accessibilitySummary: String {
        switch self {
        case .text(let text): text
        case .image(_, let alt): "Image: \(alt)"
        case .button(let title, _): "Button: \(title)"
        case .stack(let children): children.map(\.accessibilitySummary).filter { !$0.isEmpty }.joined(separator: ". ")
        case .unsupported: ""
        }
    }
}

// Decoding is an operation too: the server names the type, the app picks the case
extension Component: Decodable {
    private enum Key: String, CodingKey {
        case type, text, url, alt, title, deepLink, children
    }

    init(from decoder: any Decoder) throws {
        let json = try decoder.container(keyedBy: Key.self)
        let type = try json.decode(String.self, forKey: .type)
        switch type {
        case "text": self = .text(try json.decode(String.self, forKey: .text))
        case "image": self = .image(url: try json.decode(String.self, forKey: .url), alt: try json.decode(String.self, forKey: .alt))
        case "button": self = .button(title: try json.decode(String.self, forKey: .title), deepLink: try json.decode(String.self, forKey: .deepLink))
        case "stack": self = .stack(try json.decode([Component].self, forKey: .children))
        default: self = .unsupported(type: type)   // newer server, older app: skip it, don't fail the screen
        }
    }
}

let payload = """
{ "type": "stack", "children": [
    { "type": "text", "text": "Weekend in Lisbon" },
    { "type": "image", "url": "https://cdn.example.com/tram.jpg", "alt": "A yellow tram" },
    { "type": "carousel3d", "items": [] },
    { "type": "button", "title": "Book a table", "deepLink": "myapp://restaurants/42" }
] }
"""

let screen = try JSONDecoder().decode(Component.self, from: Data(payload.utf8))
print(screen.imagesToPrefetch)
print(screen.accessibilitySummary)
