// Generated from src/dsa/content/lessons/interview-playbook/int-clarifying.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func firstTaken(_ names: [String]) -> String? {
    var seen: Set<String> = []
    for name in names {
        if !seen.insert(name.lowercased()).inserted {
            return name
        }
    }
    return nil
}

print(firstTaken(["ana", "bo", "cy", "bo", "ana"]) ?? "none")
print(firstTaken(["Maneet", "sam", "maneet"]) ?? "none")
print(firstTaken([]) ?? "none")
print(firstTaken(["zo\u{EB}", "zoe\u{308}"]) != nil)
