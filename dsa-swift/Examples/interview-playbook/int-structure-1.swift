// Generated from src/dsa/content/lessons/interview-playbook/int-structure.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let plan = [("Clarify", 5), ("Approach", 8), ("Code", 20), ("Test and analyse", 7), ("Your questions", 5)]
var clock = 0
for (phase, minutes) in plan {
    print("\(clock)–\(clock + minutes) min: \(phase)")
    clock += minutes
}
print("Total: \(clock) min")
