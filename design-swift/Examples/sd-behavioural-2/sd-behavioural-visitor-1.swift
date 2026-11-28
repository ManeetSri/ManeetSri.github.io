// Generated from src/dsa/design/content/lessons/sd-behavioural-2/sd-behavioural-visitor.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

protocol Component {
    func accept<V: ComponentVisitor>(_ visitor: V) -> V.Result
}

struct TextBlock: Component {
    let text: String
    func accept<V: ComponentVisitor>(_ visitor: V) -> V.Result { visitor.visitText(self) }
}

struct ImageBlock: Component {
    let url: String
    let alt: String
    func accept<V: ComponentVisitor>(_ visitor: V) -> V.Result { visitor.visitImage(self) }
}

struct Stack: Component {
    let children: [any Component]
    func accept<V: ComponentVisitor>(_ visitor: V) -> V.Result { visitor.visitStack(self) }
}

// One operation over every kind of component, in one type
protocol ComponentVisitor {
    associatedtype Result
    func visitText(_ text: TextBlock) -> Result
    func visitImage(_ image: ImageBlock) -> Result
    func visitStack(_ stack: Stack) -> Result
}

// The trap: overloads are chosen at compile time, from the static type
func describe(_ text: TextBlock) -> String { "text" }
func describe(_ image: ImageBlock) -> String { "image" }
func describe(_ component: any Component) -> String { "some component" }

let screen = Stack(children: [
    TextBlock(text: "Weekend in Lisbon"),
    ImageBlock(url: "https://cdn.example.com/tram.jpg", alt: "A yellow tram"),
    Stack(children: [ImageBlock(url: "https://cdn.example.com/view.jpg", alt: "The view from a hill")]),
])

print(screen.children.map { describe($0) })

// The fix: two dynamic dispatches, first on the component, then on the visitor
struct Describer: ComponentVisitor {
    func visitText(_ text: TextBlock) -> String { "text" }
    func visitImage(_ image: ImageBlock) -> String { "image" }
    func visitStack(_ stack: Stack) -> String { "stack of \(stack.children.count)" }
}

print(screen.children.map { $0.accept(Describer()) })

// A second operation is a second visitor; no component changes
struct ImagesToPrefetch: ComponentVisitor {
    func visitText(_ text: TextBlock) -> [String] { [] }
    func visitImage(_ image: ImageBlock) -> [String] { [image.url] }
    func visitStack(_ stack: Stack) -> [String] { stack.children.flatMap { $0.accept(self) } }
}

print(screen.accept(ImagesToPrefetch()))
