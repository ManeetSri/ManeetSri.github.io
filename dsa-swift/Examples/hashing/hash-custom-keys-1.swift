// Generated from src/dsa/content/lessons/hashing/hash-custom-keys.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Username: Hashable {
    let value: String

    init(_ raw: String) {
        value = raw.lowercased()      // normalise once, here
    }
}

var lastLogin: [Username: String] = [:]
lastLogin[Username("Maneet")] = "Monday"
lastLogin[Username("MANEET")] = "Friday"

print(lastLogin.count)
print(lastLogin[Username("maneet")] ?? "never")
