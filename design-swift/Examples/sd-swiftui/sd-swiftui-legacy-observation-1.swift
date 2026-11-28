// Generated from src/dsa/design/content/lessons/sd-swiftui/sd-swiftui-legacy-observation.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Combine

final class Basket: ObservableObject {
    @Published var title = "Weekly shop"
    @Published var count = 0
}

let basket = Basket()
var invalidations = 0

// What SwiftUI does for each view that observes the basket
let subscription = basket.objectWillChange.sink { _ in
    invalidations += 1
    print("will change: count is still \(basket.count)")
}

basket.title = "Party"
basket.count += 1
basket.count += 1
print("A view showing only the count was invalidated \(invalidations) times")
subscription.cancel()
