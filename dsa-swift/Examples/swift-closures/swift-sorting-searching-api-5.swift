// Generated from src/dsa/content/lessons/swift-closures/swift-sorting-searching-api.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let people = [(name: "Cleo", age: 29), (name: "Ada", age: 36), (name: "Ben", age: 29)]

let byAgeThenName = people.sorted { ($0.age, $0.name) < ($1.age, $1.name) }
for person in byAgeThenName {
    print(person.name, person.age)
}
