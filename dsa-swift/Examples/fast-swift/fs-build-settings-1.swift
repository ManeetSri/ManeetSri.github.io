// Generated from src/dsa/content/lessons/fast-swift/fs-build-settings.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// FNV-1a, a simple hash that relies on multiplication wrapping around
var hash: UInt64 = 14_695_981_039_346_656_037
for byte in "swift".utf8 {
    hash = (hash ^ UInt64(byte)) &* 1_099_511_628_211
}
print(hash)
print(Int8.max &+ 1)
