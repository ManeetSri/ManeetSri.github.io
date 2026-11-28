// Generated from src/dsa/content/lessons/swift-functions/swift-nested-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func makeTea() {
    var stepNumber = 0

    func step(_ instruction: String) {
        stepNumber += 1
        print("\(stepNumber). \(instruction)")
    }

    step("Boil the kettle")
    step("Add a tea bag")
    step("Pour and wait three minutes")
    print("Done in \(stepNumber) steps")
}

makeTea()
