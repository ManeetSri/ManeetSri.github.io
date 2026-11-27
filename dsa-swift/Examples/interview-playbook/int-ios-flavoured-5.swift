// Generated from src/dsa/content/lessons/interview-playbook/int-ios-flavoured.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class View {
    let name: String
    private(set) var subviews: [View] = []
    private(set) weak var superview: View?     // weak: the parent owns the child, not the reverse

    init(_ name: String) {
        self.name = name
    }

    func addSubview(_ view: View) {
        view.superview = self
        subviews.append(view)
    }
}

// Flatten: preorder with an explicit stack, indenting by depth
func flatten(_ root: View) -> [String] {
    var lines: [String] = []
    var stack = [(view: root, depth: 0)]
    while let (view, depth) = stack.popLast() {
        lines.append(String(repeating: "  ", count: depth) + view.name)
        for child in view.subviews.reversed() {   // reversed, so the first subview comes out first
            stack.append((child, depth + 1))
        }
    }
    return lines
}

// Nearest common superview: level the depths, then climb together
func depth(of view: View) -> Int {
    var depth = 0
    var current = view
    while let parent = current.superview {
        depth += 1
        current = parent
    }
    return depth
}

func commonSuperview(_ a: View, _ b: View) -> View? {
    var x: View? = a
    var y: View? = b
    var depthX = depth(of: a)
    var depthY = depth(of: b)
    while depthX > depthY { x = x?.superview; depthX -= 1 }
    while depthY > depthX { y = y?.superview; depthY -= 1 }
    while let p = x, let q = y, p !== q {        // !== compares identity, not contents
        x = p.superview
        y = q.superview
    }
    return x                                     // nil if they're in different windows
}

let window = View("window")
let header = View("header"), list = View("list")
let title = View("title"), avatar = View("avatar")
let cell0 = View("cell0"), cell1 = View("cell1")
let label0 = View("label0"), label1 = View("label1")
window.addSubview(header)
window.addSubview(list)
header.addSubview(title)
header.addSubview(avatar)
list.addSubview(cell0)
list.addSubview(cell1)
cell0.addSubview(label0)
cell1.addSubview(label1)

print(flatten(window).joined(separator: "\n"))
print(commonSuperview(label0, label1)?.name ?? "none")
print(commonSuperview(title, label1)?.name ?? "none")
print(commonSuperview(cell0, label0)?.name ?? "none")
print(commonSuperview(label0, View("alert"))?.name ?? "none")
