// Generated from src/dsa/design/content/lessons/sd-swift-design/sd-swift-design-noncopyable.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct FileDescriptor: ~Copyable {
    let raw: Int32

    consuming func close() {
        print("close(\(raw))")
        discard self            // closed by hand, so skip deinit
    }

    deinit {
        print("deinit closes \(raw)")
    }
}

func readConfig() {
    let file = FileDescriptor(raw: 3)
    print("reading from \(file.raw)")
    file.close()
}

func forgetToClose() {
    let file = FileDescriptor(raw: 4)
    print("reading from \(file.raw)")
}   // nobody closed it, so its deinit runs here

readConfig()
forgetToClose()
