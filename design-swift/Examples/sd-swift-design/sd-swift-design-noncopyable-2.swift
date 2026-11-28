// Generated from src/dsa/design/content/lessons/sd-swift-design/sd-swift-design-noncopyable.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct UploadDraft: ~Copyable {
    let fileName: String

    consuming func start(session: Int) -> ActiveUpload {
        ActiveUpload(fileName: fileName, session: session)
    }
}

struct ActiveUpload: ~Copyable {
    let fileName: String
    let session: Int
    private(set) var bytesSent = 0

    mutating func send(_ bytes: Int) {
        bytesSent += bytes
    }

    consuming func finish() -> UploadReceipt {
        UploadReceipt(fileName: fileName, session: session, bytes: bytesSent)
    }

    consuming func cancel() -> Int {
        session
    }
}

struct UploadReceipt {
    let fileName: String
    let session: Int
    let bytes: Int
}

func uploadVideo() -> UploadReceipt {
    let draft = UploadDraft(fileName: "holiday.mov")
    var upload = draft.start(session: 41)
    upload.send(5_000)
    upload.send(2_500)
    return upload.finish()
}

let receipt = uploadVideo()
print("\(receipt.fileName): \(receipt.bytes) bytes in session \(receipt.session)")
