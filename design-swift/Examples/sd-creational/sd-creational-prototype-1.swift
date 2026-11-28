// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-prototype.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

final class ItemStorage {
    var items: [String]
    init(_ items: [String]) { self.items = items }
}

// A value type with copy-on-write: copies share storage until one of them changes
struct PackingList {
    private var storage: ItemStorage

    init(_ items: [String]) { storage = ItemStorage(items) }

    var items: [String] { storage.items }

    mutating func add(_ item: String) {
        if !isKnownUniquelyReferenced(&storage) {
            print("  copying storage before adding \(item)")
            storage = ItemStorage(storage.items)
        }
        storage.items.append(item)
    }
}

let template = PackingList(["Passport", "Charger"])
var beach = template
var ski = template
print("Two copies made; no storage copied yet")

beach.add("Sunscreen")
ski.add("Gloves")
ski.add("Goggles")

print(template.items)
print(beach.items)
print(ski.items)
