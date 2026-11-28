// Generated from src/dsa/design/content/lessons/sd-diagnostics/sd-diag-typed-throws.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Photo: Sendable {
    let name: String
    let megabytes: Int
}

enum UploadError: Error {
    case tooLarge(limitMB: Int)
    case unsupportedFormat
}

func upload(_ photo: Photo) async throws(UploadError) -> String {
    if !photo.name.hasSuffix(".heic") && !photo.name.hasSuffix(".jpg") { throw .unsupportedFormat }
    if photo.megabytes > 25 { throw .tooLarge(limitMB: 25) }
    return "photos/\(photo.name)"
}

// Every child returns a Result, so one failure doesn't cancel the other uploads
func uploadAll(_ photos: [Photo]) async -> [Result<String, UploadError>] {
    await withTaskGroup(of: (Int, Result<String, UploadError>).self) { group in
        for (index, photo) in photos.enumerated() {
            group.addTask {
                do throws(UploadError) {
                    return (index, .success(try await upload(photo)))
                } catch {
                    return (index, .failure(error))
                }
            }
        }
        var results = [Result<String, UploadError>?](repeating: nil, count: photos.count)
        for await (index, result) in group {
            results[index] = result      // children finish in any order; keep the input's order
        }
        return results.compactMap { $0 }
    }
}

let photos = [
    Photo(name: "beach.heic", megabytes: 4),
    Photo(name: "panorama.heic", megabytes: 60),
    Photo(name: "scan.tiff", megabytes: 9),
    Photo(name: "dinner.jpg", megabytes: 3),
]
let results = await uploadAll(photos)
for (photo, result) in zip(photos, results) {
    switch result {
    case .success(let path): print("\(photo.name): uploaded to \(path)")
    case .failure(.tooLarge(let limit)): print("\(photo.name): larger than \(limit) MB")
    case .failure(.unsupportedFormat): print("\(photo.name): format not supported")
    }
}
let uploaded = results.filter { (try? $0.get()) != nil }.count
print("\(uploaded) of \(photos.count) uploaded")
