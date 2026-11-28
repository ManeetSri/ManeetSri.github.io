// Reference solution: Order the courses. Kahn's algorithm: count how many prerequisites each course
// is waiting on, start a queue with the courses waiting on none, and repeatedly take one, append it
// to the order, and release the courses it unlocks. A course joins the queue only once all of its
// prerequisites are in the order, so the order is valid. If a cycle leaves some courses stuck, the
// order comes up short, and the answer is []. O(n + p) time and space, with no recursion.

public enum CourseStudyOrder {
    public static func order(courseCount: Int, prerequisites: [[Int]]) -> [Int] {
        var unlocks = Array(repeating: [Int](), count: courseCount)
        var waitingOn = Array(repeating: 0, count: courseCount)
        for pair in prerequisites {
            unlocks[pair[0]].append(pair[1])
            waitingOn[pair[1]] += 1
        }
        var order = (0..<courseCount).filter { waitingOn[$0] == 0 }
        var head = 0                                                 // order doubles as the queue
        while head < order.count {
            let course = order[head]
            head += 1
            for next in unlocks[course] {
                waitingOn[next] -= 1
                if waitingOn[next] == 0 {
                    order.append(next)
                }
            }
        }
        return order.count == courseCount ? order : []
    }
}
