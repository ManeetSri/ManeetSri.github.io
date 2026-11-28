// Generated from src/dsa/content/lessons/swift-generics/swift-hashable.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Student: Hashable {
    var id: Int
    var nickname: String

    static func == (lhs: Student, rhs: Student) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

let records = [
    Student(id: 7, nickname: "Mo"),
    Student(id: 3, nickname: "Bea"),
    Student(id: 7, nickname: "Mohammed"),
]
let unique = Set(records)
print(unique.count)
print(unique.map { $0.id }.sorted())
