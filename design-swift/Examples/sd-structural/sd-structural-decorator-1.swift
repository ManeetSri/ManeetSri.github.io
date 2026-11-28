// Generated from src/dsa/design/content/lessons/sd-structural/sd-structural-decorator.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

protocol ForecastService: Sendable {
    func forecast(for city: String) async throws -> String
}

struct RemoteForecasts: ForecastService {
    func forecast(for city: String) async throws -> String {
        print("    network: GET /forecast?city=\(city)")
        return "\(city): 14°C, showers"
    }
}

// A decorator: the same interface, plus one more job
struct LoggingForecasts: ForecastService {
    let wrapped: any ForecastService

    func forecast(for city: String) async throws -> String {
        print("  log: forecast(\(city))")
        return try await wrapped.forecast(for: city)
    }
}

// Another decorator. It's an actor because many tasks may call it at once.
actor CachingForecasts: ForecastService {
    private let wrapped: any ForecastService
    private var cache: [String: String] = [:]

    init(wrapping wrapped: any ForecastService) {
        self.wrapped = wrapped
    }

    func forecast(for city: String) async throws -> String {
        if let cached = cache[city] { return cached }
        let fresh = try await wrapped.forecast(for: city)
        cache[city] = fresh
        return fresh
    }
}

func ask(_ service: any ForecastService) async throws {
    for city in ["Leeds", "Leeds", "York"] {
        _ = try await service.forecast(for: city)
    }
}

print("Logging outside the cache:")
try await ask(LoggingForecasts(wrapped: CachingForecasts(wrapping: RemoteForecasts())))

print("Logging inside the cache:")
try await ask(CachingForecasts(wrapping: LoggingForecasts(wrapped: RemoteForecasts())))
