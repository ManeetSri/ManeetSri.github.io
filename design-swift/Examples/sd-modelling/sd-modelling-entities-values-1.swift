// Generated from src/dsa/design/content/lessons/sd-modelling/sd-modelling-entities-values.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

/// A value: two addresses with the same lines are the same address
struct PostalAddress: Hashable, Sendable {
    let line1: String
    let city: String
    let postcode: String
}

/// An entity: identified by `id`, whatever else changes
struct Customer: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var address: PostalAddress
}

let id = UUID(uuidString: "6F1C2D8E-4A5B-4C3D-9E8F-1A2B3C4D5E6F")!
let leeds = PostalAddress(line1: "1 High St", city: "Leeds", postcode: "LS1 1AA")
let before = Customer(id: id, name: "Sam Lee", address: leeds)

var after = before
after.address = PostalAddress(line1: "9 Park Rd", city: "York", postcode: "YO1 7HH")
after.name = "Samira Lee"

print("Same customer? \(before.id == after.id)")
print("Same snapshot? \(before == after)")
print("Same address as a fresh copy? \(leeds == PostalAddress(line1: "1 High St", city: "Leeds", postcode: "LS1 1AA"))")

// Find an entity by its identity, then replace the old snapshot
var customers = [before]
if let index = customers.firstIndex(where: { $0.id == after.id }) {
    customers[index] = after
}
print(customers.map(\.name))
