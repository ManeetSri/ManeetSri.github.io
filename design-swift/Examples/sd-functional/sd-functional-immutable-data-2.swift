// Generated from src/dsa/design/content/lessons/sd-functional/sd-functional-immutable-data.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Message: Equatable {
    enum Status { case sending, sent, read }
    let id: Int
    var text: String
    var status: Status
}

struct Conversation {
    var messages: [Message]

    /// A copy of the conversation with one message marked as read
    func markingRead(_ id: Int) -> Conversation {
        var copy = self
        if let index = copy.messages.firstIndex(where: { $0.id == id }) {
            copy.messages[index].status = .read
        }
        return copy
    }
}

func sameBuffer(_ a: [Message], _ b: [Message]) -> Bool {
    a.withUnsafeBufferPointer { x in b.withUnsafeBufferPointer { y in x.baseAddress == y.baseAddress } }
}

let before = Conversation(messages: (1...3).map { Message(id: $0, text: "Message \($0)", status: .sent) })
let after = before.markingRead(2)

print(before.messages.map { "\($0.status)" })
print(after.messages.map { "\($0.status)" })

var shared = before
print(sameBuffer(before.messages, shared.messages))
shared.messages[0].text = "Edited"
print(sameBuffer(before.messages, shared.messages))
print(before.messages[0].text)
