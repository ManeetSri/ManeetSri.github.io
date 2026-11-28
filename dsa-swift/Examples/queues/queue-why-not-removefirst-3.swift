// Generated from src/dsa/content/lessons/queues/queue-why-not-removefirst.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var jobs = ["A", "B", "C", "D"]
jobs.reverse()                      // O(n), once
var order: [String] = []
while let job = jobs.popLast() {    // O(1) each
    order.append(job)
}
print(order)
