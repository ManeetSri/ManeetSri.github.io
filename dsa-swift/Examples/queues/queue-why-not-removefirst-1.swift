// Generated from src/dsa/content/lessons/queues/queue-why-not-removefirst.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var line: [String] = []
line.append("Ana")                 // enqueue
line.append("Ben")
line.append("Cleo")
print(line.first ?? "nobody")      // peek
let served = line.removeFirst()    // dequeue
print(served, line)
line.append("Dev")
print(line.removeFirst(), line)
