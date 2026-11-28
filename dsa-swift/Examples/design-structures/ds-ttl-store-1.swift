// Generated from src/dsa/content/lessons/design-structures/ds-ttl-store.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let setAt = 100, ttl = 30
for now in [129, 130] {
    print(now, now < setAt + ttl ? "live" : "expired")
}
