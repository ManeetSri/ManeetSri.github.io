// Generated from src/dsa/content/lessons/design-structures/ds-ttl-store.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct LazyTTLStore {
    private var entries: [String: (value: String, expiresAt: Int)] = [:]

    var stored: Int { entries.count }

    mutating func set(_ value: String, for key: String, ttl: Int, now: Int) {
        entries[key] = (value, now + ttl)              // live while now < expiresAt
    }

    mutating func value(for key: String, now: Int) -> String? {
        guard let entry = entries[key] else { return nil }
        if entry.expiresAt <= now {
            entries[key] = nil                         // found dead on read: clean it up now
            return nil
        }
        return entry.value
    }
}

var sessions = LazyTTLStore()
sessions.set("token-a", for: "ana", ttl: 30, now: 0)
sessions.set("token-m", for: "maneet", ttl: 60, now: 10)
print(sessions.value(for: "ana", now: 29) ?? "expired")
print(sessions.value(for: "ana", now: 30) ?? "expired")
print(sessions.value(for: "maneet", now: 69) ?? "expired")
for guest in 0..<1_000 {
    sessions.set("token-g", for: "guest\(guest)", ttl: 5, now: 100)
}
print("stored, though every one has expired by time 200:", sessions.stored)
