// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-prototype.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

final class AttachmentList {
    var names: [String] = []
}

struct Draft {
    var subject: String
    let attachments: AttachmentList
}

let template = Draft(subject: "Weekly report", attachments: AttachmentList())
var mine = template
mine.subject = "Weekly report: week 12"
mine.attachments.names.append("figures.pdf")

print(template.subject)
print(template.attachments.names)
