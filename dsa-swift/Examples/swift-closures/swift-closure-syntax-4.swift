// Generated from src/dsa/content/lessons/swift-closures/swift-closure-syntax.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func repeatAction(times: Int, action: (Int) -> Void) {
    for round in 1...times {
        action(round)
    }
}

repeatAction(times: 3) { round in
    print("Round \(round)")
}

repeatAction(times: 2) {
    print("Hip hip... \($0)")
}
