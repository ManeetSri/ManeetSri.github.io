// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-prototype.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// A drawing app's canvas items: the canvas copies whatever is selected without knowing its class
class CanvasItem {
    var x: Double
    var y: Double

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    // Every subclass must be able to copy itself, so clone() can return Self
    required init(copying other: CanvasItem) {
        x = other.x
        y = other.y
    }

    func clone() -> Self {
        Self(copying: self)
    }

    var summary: String { "item at (\(x), \(y))" }
}

final class TextBox: CanvasItem {
    var text: String

    init(text: String, x: Double, y: Double) {
        self.text = text
        super.init(x: x, y: y)
    }

    required init(copying other: CanvasItem) {
        text = (other as? TextBox)?.text ?? ""
        super.init(copying: other)
    }

    override var summary: String { "text \"\(text)\" at (\(x), \(y))" }
}

func duplicate(_ selection: [CanvasItem], offsetBy offset: Double) -> [CanvasItem] {
    selection.map { item in
        let copy = item.clone()
        copy.x += offset
        copy.y += offset
        return copy
    }
}

let selection: [CanvasItem] = [TextBox(text: "Hello", x: 10, y: 20), CanvasItem(x: 0, y: 0)]
for item in duplicate(selection, offsetBy: 8) {
    print(type(of: item), item.summary)
}
print(selection[0].summary)
