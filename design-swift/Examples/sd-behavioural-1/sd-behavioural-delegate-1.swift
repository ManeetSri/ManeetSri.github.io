// Generated from src/dsa/design/content/lessons/sd-behavioural-1/sd-behavioural-delegate.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

protocol DownloaderDelegate: AnyObject {
    func downloader(_ downloader: Downloader, didFinish file: String)
    func downloader(_ downloader: Downloader, shouldRetryAfter attempts: Int) -> Bool
}

final class Downloader {
    weak var delegate: DownloaderDelegate?

    /// Pretends the first `failures` attempts fail, asking the delegate before each retry
    func download(_ file: String, failures: Int) {
        for attempt in stride(from: 1, through: failures, by: 1) {
            print("Attempt \(attempt) failed")
            guard delegate?.downloader(self, shouldRetryAfter: attempt) == true else {
                print("Giving up on \(file)")
                return
            }
        }
        delegate?.downloader(self, didFinish: file)
    }
}

final class EpisodeScreen: DownloaderDelegate {
    let downloader = Downloader()

    init() {
        downloader.delegate = self
    }

    func downloader(_ downloader: Downloader, didFinish file: String) {
        print("Screen shows \(file) as downloaded")
    }

    func downloader(_ downloader: Downloader, shouldRetryAfter attempts: Int) -> Bool {
        attempts < 3
    }

    deinit {
        print("Screen freed")
    }
}

var screen: EpisodeScreen? = EpisodeScreen()
screen?.downloader.download("episode-12.mp3", failures: 2)
screen?.downloader.download("episode-13.mp3", failures: 5)
screen = nil
print("Done")
