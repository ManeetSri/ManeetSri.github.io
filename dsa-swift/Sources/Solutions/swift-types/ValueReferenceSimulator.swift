// Reference solution: Value or reference? Memory is modelled as a list of things, and each variable holds
// the number of the thing it uses. The two kinds differ in one place: copying a struct makes a new thing
// with the same value, while copying a class shares the existing thing. O(1) per command, O(n) overall.

public enum ValueReferenceSimulator {
    public static func run(_ commands: [String], usingClasses: Bool) -> [Int] {
        var values: [Int] = []                  // values[thing] is that thing's current value
        var thingOf: [String: Int] = [:]        // which thing each variable uses
        var shown: [Int] = []

        for command in commands {
            let words = command.split(separator: " ").map(String.init)
            switch words[0] {
            case "new":
                values.append(Int(words[2])!)
                thingOf[words[1]] = values.count - 1
            case "copy":
                let source = thingOf[words[2]]!
                if usingClasses {
                    thingOf[words[1]] = source                  // share the same object
                } else {
                    values.append(values[source])               // an independent copy
                    thingOf[words[1]] = values.count - 1
                }
            case "add":
                values[thingOf[words[1]]!] += Int(words[2])!
            default:                                            // "show"
                shown.append(values[thingOf[words[1]]!])
            }
        }
        return shown
    }
}
