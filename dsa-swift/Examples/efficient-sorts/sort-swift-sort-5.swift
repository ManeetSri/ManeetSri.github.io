// Generated from src/dsa/content/lessons/efficient-sorts/sort-swift-sort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Two stable sorts in a row: the second key wins, and the first key breaks its ties
struct Employee {
    let name: String
    let team: String
}

let staff = [
    Employee(name: "Priya", team: "Mobile"),
    Employee(name: "Leo", team: "Web"),
    Employee(name: "Amara", team: "Mobile"),
    Employee(name: "Chen", team: "Web"),
    Employee(name: "Bea", team: "Mobile"),
]

let byName = staff.sorted { $0.name < $1.name }
let byTeamThenName = byName.sorted { $0.team < $1.team }   // stable: names stay A to Z within a team
print(byTeamThenName.map { "\($0.team) \($0.name)" })
