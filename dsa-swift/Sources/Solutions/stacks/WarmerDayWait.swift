// Reference solution: Wait for a warmer day. A stack holds the days still waiting for a warmer one;
// their temperatures never increase from bottom to top. Each new day pops (and answers) every
// waiting day that's colder, then waits itself. Every day is pushed and popped at most once:
// O(n) time, O(n) space.

public enum WarmerDayWait {
    public static func daysToWait(_ temperatures: [Int]) -> [Int] {
        var waits = Array(repeating: 0, count: temperatures.count)
        var waiting: [Int] = []
        for (day, temperature) in temperatures.enumerated() {
            while let colder = waiting.last, temperatures[colder] < temperature {
                waits[colder] = day - colder
                waiting.removeLast()
            }
            waiting.append(day)
        }
        return waits
    }
}
