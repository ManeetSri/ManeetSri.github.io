// Generated from src/dsa/design/content/lessons/sd-behavioural-1/sd-behavioural-kvo-combine-observation.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Combine

final class Basket {
    @Published var count = 0
}

let basket = Basket()
let subscription = basket.$count.sink { newValue in
    print("sink got \(newValue), property still says \(basket.count)")
}
basket.count = 1
basket.count = 2
subscription.cancel()
basket.count = 3
print("after cancel: nothing printed for 3")
