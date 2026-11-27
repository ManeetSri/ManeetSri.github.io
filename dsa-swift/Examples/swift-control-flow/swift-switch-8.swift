// Generated from src/dsa/content/lessons/swift-control-flow/swift-switch.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let hasTicket = true
let hasID = false

switch (hasTicket, hasID) {
case (true, true):
    print("Board the plane")
case (true, false):
    print("Show some ID first")
case (false, true):
    print("Buy a ticket first")
case (false, false):
    print("Buy a ticket and bring ID")
}
