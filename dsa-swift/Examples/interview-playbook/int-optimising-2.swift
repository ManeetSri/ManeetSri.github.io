// Generated from src/dsa/content/lessons/interview-playbook/int-optimising.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func waitSlow(_ temps: [Int]) -> [Int] {
    var answer = Array(repeating: 0, count: temps.count)
    for day in temps.indices {
        for later in (day + 1)..<temps.count where temps[later] > temps[day] {
            answer[day] = later - day
            break
        }
    }
    return answer
}

func waitFast(_ temps: [Int]) -> [Int] {
    var answer = Array(repeating: 0, count: temps.count)
    var waiting: [Int] = []            // days still waiting, temperatures falling
    for (day, temp) in temps.enumerated() {
        while let last = waiting.last, temps[last] < temp {
            answer[last] = day - last
            waiting.removeLast()
        }
        waiting.append(day)
    }
    return answer
}

let temps = [13, 12, 15, 11, 9, 12, 16]
print(waitSlow(temps))
print(waitFast(temps))
