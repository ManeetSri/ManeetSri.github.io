// Generated from src/dsa/design/content/lessons/sd-diagrams/sd-diagrams-uml-class.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Adjustment {
    var name: String
    var amount: Double
}

// Composition: the adjustments are values, copied with the recipe
struct Recipe {
    var adjustments: [Adjustment]
}

// Association: the look refers to a shared lookup table
final class LookupTable {
    var name: String
    init(name: String) { self.name = name }
}

struct Look {
    var table: LookupTable
}

let original = Recipe(adjustments: [Adjustment(name: "Exposure", amount: 0.5)])
var edited = original
edited.adjustments[0].amount = 1.0
print("Recipe: original \(original.adjustments[0].amount), edited \(edited.adjustments[0].amount)")

let film = LookupTable(name: "Film")
let warm = Look(table: film)
let copy = warm
warm.table.name = "Warm film"
print("Look: the copy now uses \"\(copy.table.name)\"")
