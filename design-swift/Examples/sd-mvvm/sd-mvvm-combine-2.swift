// Generated from src/dsa/design/content/lessons/sd-mvvm/sd-mvvm-combine.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Combine

final class Form: ObservableObject {
    @Published var name = ""
}

let form = Form()
let subscription = form.$name.sink { newValue in
    print("received \"\(newValue)\", property is \"\(form.name)\"")
}
form.name = "Ada"
subscription.cancel()
