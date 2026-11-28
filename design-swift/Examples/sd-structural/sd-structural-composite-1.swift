// Generated from src/dsa/design/content/lessons/sd-structural/sd-structural-composite.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Comment {
    let author: String
    let text: String
    var replies: [Comment] = []

    // Every operation: this comment's part, combined with its replies' answers
    var totalCount: Int {
        1 + replies.reduce(0) { $0 + $1.totalCount }
    }

    var depth: Int {
        1 + (replies.map(\.depth).max() ?? 0)
    }

    func printThread(indent: Int = 0) {
        print(String(repeating: "  ", count: indent) + "\(author): \(text)")
        for reply in replies {
            reply.printThread(indent: indent + 1)
        }
    }
}

let thread = Comment(author: "Asha", text: "Which architecture for a small app?", replies: [
    Comment(author: "Ben", text: "MVVM, kept simple.", replies: [
        Comment(author: "Asha", text: "Even for one screen?", replies: [
            Comment(author: "Ben", text: "Then plain SwiftUI state is enough."),
        ]),
    ]),
    Comment(author: "Chen", text: "Whatever the team already knows."),
])

thread.printThread()
print("\(thread.totalCount) comments, \(thread.depth) levels deep")
