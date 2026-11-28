// Generated from src/dsa/design/content/lessons/sd-realtime/sd-rt-sse.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct ServerEvent: Equatable, Sendable {
    var type = "message"
    var data = ""
    var id: String?
}

/// Turns the bytes of a text/event-stream into events, as they arrive
struct EventStreamParser {
    /// The id to send back as Last-Event-ID when reconnecting
    private(set) var lastEventID: String?
    /// How long the server asked clients to wait before reconnecting
    private(set) var retry: Duration?
    private var line: [UInt8] = []
    private var afterCarriageReturn = false
    private var type = ""
    private var dataLines: [String] = []

    mutating func feed(_ byte: UInt8) -> ServerEvent? {
        // A line ends at \n, \r or \r\n; count \r\n once
        if byte == UInt8(ascii: "\n"), afterCarriageReturn {
            afterCarriageReturn = false
            return nil
        }
        afterCarriageReturn = byte == UInt8(ascii: "\r")
        guard byte == UInt8(ascii: "\n") || byte == UInt8(ascii: "\r") else {
            line.append(byte)
            return nil
        }
        defer { line.removeAll(keepingCapacity: true) }
        return process(String(decoding: line, as: UTF8.self))
    }

    private mutating func process(_ line: String) -> ServerEvent? {
        if line.isEmpty { return dispatch() }     // a blank line ends the event
        if line.hasPrefix(":") { return nil }     // a comment, usually a heartbeat
        var field = Substring(line)
        var value: Substring = ""
        if let colon = line.firstIndex(of: ":") {
            field = line[..<colon]
            value = line[line.index(after: colon)...]
            if value.hasPrefix(" ") { value = value.dropFirst() }
        }
        switch field {
        case "event": type = String(value)
        case "data": dataLines.append(String(value))
        case "id": lastEventID = String(value)
        case "retry": if let milliseconds = Int(value) { retry = .milliseconds(milliseconds) }
        default: break                            // unknown fields are ignored, so the format can grow
        }
        return nil
    }

    private mutating func dispatch() -> ServerEvent? {
        defer {
            type = ""
            dataLines = []
        }
        guard !dataLines.isEmpty else { return nil }
        return ServerEvent(type: type.isEmpty ? "message" : type, data: dataLines.joined(separator: "\n"), id: lastEventID)
    }
}

/// Streams events from an endpoint. To resume after a drop, call it again with the last event's id.
func events(from url: URL, lastEventID: String?, session: URLSession = .shared) -> AsyncThrowingStream<ServerEvent, any Error> {
    AsyncThrowingStream { continuation in
        let task = Task {
            var request = URLRequest(url: url)
            request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
            if let lastEventID { request.setValue(lastEventID, forHTTPHeaderField: "Last-Event-ID") }
            do {
                let (bytes, response) = try await session.bytes(for: request)
                guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
                var parser = EventStreamParser()
                // Byte by byte, not bytes.lines: lines skips empty lines, and they're what end an event
                for try await byte in bytes {
                    if let event = parser.feed(byte) { continuation.yield(event) }
                }
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
        continuation.onTermination = { _ in task.cancel() }
    }
}

// What a live-score endpoint might send: a heartbeat, two scores and a two-line message
let stream = """
retry: 5000
: keep-alive

event: score
id: 41
data: {"home": 1, "away": 0}

data: Half time.
data: Back in 15 minutes.

event: score
id: 42
data: {"home": 2, "away": 0}


"""
var parser = EventStreamParser()
for byte in stream.utf8 {
    if let event = parser.feed(byte) {
        print("[\(event.type) · id \(event.id ?? "none")] \(event.data)")
    }
}
print("Reconnect with Last-Event-ID \(parser.lastEventID ?? "none"), after \(parser.retry ?? .seconds(3))")
