// Reference solution: Split rivals into two teams. A two-colouring with BFS: give the first person of
// each component team 0, and every rival of a person the opposite team. If a rival already has the
// same team as the person, there's an odd cycle of rivalries and no split exists. The outer loop
// starts a new BFS from everyone not yet placed, so separate groups are all handled. One head-index
// queue serves every component. O(people + rivalries) time and space.

public enum RivalTeamSplit {
    public static func teams(_ people: Int, rivalries: [[Int]]) -> [Int]? {
        var rivals = Array(repeating: [Int](), count: people)
        for pair in rivalries {
            rivals[pair[0]].append(pair[1])
            rivals[pair[1]].append(pair[0])
        }

        var team = Array(repeating: -1, count: people)
        var queue: [Int] = []
        var head = 0
        for first in 0..<people where team[first] == -1 {
            team[first] = 0
            queue.append(first)
            while head < queue.count {
                let person = queue[head]
                head += 1
                for rival in rivals[person] {
                    if team[rival] == -1 {
                        team[rival] = 1 - team[person]
                        queue.append(rival)
                    } else if team[rival] == team[person] {
                        return nil                       // an odd cycle: two rivals on one team
                    }
                }
            }
        }
        return team
    }
}
