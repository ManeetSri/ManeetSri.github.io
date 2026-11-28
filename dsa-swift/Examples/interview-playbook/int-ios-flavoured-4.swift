// Generated from src/dsa/content/lessons/interview-playbook/int-ios-flavoured.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let old = ["Inbox", "Drafts", "Sent", "Spam"]
let new = ["Inbox", "Starred", "Sent", "Archive"]
for change in new.difference(from: old) {
    switch change {
    case let .remove(offset, element, _):
        print("delete old row \(offset): \(element)")
    case let .insert(offset, element, _):
        print("insert new row \(offset): \(element)")
    }
}
