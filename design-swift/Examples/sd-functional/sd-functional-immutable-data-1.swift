// Generated from src/dsa/design/content/lessons/sd-functional/sd-functional-immutable-data.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct DraftValue { var title: String }
final class DraftObject { var title: String; init(title: String) { self.title = title } }

let value = DraftValue(title: "Groceries")
var valueCopy = value
valueCopy.title = "Shopping"

let object = DraftObject(title: "Groceries")
let sameObject = object
sameObject.title = "Shopping"

print(value.title, valueCopy.title)
print(object.title, sameObject.title)
