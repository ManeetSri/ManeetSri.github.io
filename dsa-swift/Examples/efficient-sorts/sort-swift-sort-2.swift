// Generated from src/dsa/content/lessons/efficient-sorts/sort-swift-sort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Contact {
    let first: String
    let last: String
}

let contacts = [
    Contact(first: "Ravi", last: "Shah"),
    Contact(first: "Ana", last: "Lima"),
    Contact(first: "Dev", last: "Shah"),
    Contact(first: "Ben", last: "Lima"),
]

// By last name, then first name: tuples compare element by element, left to right
let byName = contacts.sorted { ($0.last, $0.first) < ($1.last, $1.first) }
print(byName.map { "\($0.first) \($0.last)" })

// Last name Z to A, then first name A to Z: swap only the parts that go downwards
let mixed = contacts.sorted { ($1.last, $0.first) < ($0.last, $1.first) }
print(mixed.map { "\($0.first) \($0.last)" })
