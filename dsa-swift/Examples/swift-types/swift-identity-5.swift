// Generated from src/dsa/content/lessons/swift-types/swift-identity.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Room {
    let name: String

    init(name: String) {
        self.name = name
    }
}

let hall = Room(name: "Hall")
let kitchen = Room(name: "Kitchen")
let route = [hall, kitchen, hall, hall, kitchen]

var visited = Set<ObjectIdentifier>()
for room in route {
    let isNew = visited.insert(ObjectIdentifier(room)).inserted
    print(room.name, isNew ? "(new)" : "(seen before)")
}
print("Different rooms:", visited.count)
