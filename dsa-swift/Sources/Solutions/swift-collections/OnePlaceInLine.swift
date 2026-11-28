// Reference solution: One place in line. An array keeps the order, a head index makes serving
// O(1), and a set answers "already waiting?" in O(1) on average. O(n) time, O(n) space.

public enum OnePlaceInLine {
    public static func servedOrder(_ events: [String]) -> [String] {
        var line: [String] = []
        var head = 0
        var waiting = Set<String>()
        var served: [String] = []
        for event in events {
            if event == "NEXT" {
                if head < line.count {
                    let person = line[head]
                    head += 1
                    waiting.remove(person)
                    served.append(person)
                }
            } else if waiting.insert(event).inserted {
                line.append(event)
            }
        }
        return served
    }
}
