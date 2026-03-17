import Foundation

class MovieAPIService {
    static let shared = MovieAPIService()
    private init() {}

    // MARK: - Search Movies
    func searchMovies(query: String, page: Int = 1, completion: @escaping (Result<MovieSearchResponse, Error>) -> Void) {
        var components = URLComponents(string: "\(Constants.baseURL)/search/movie")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: Constants.apiKey),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        performRequest(url: components.url!, completion: completion)
    }

    // MARK: - Trending
    func fetchTrending(page: Int = 1, completion: @escaping (Result<MovieSearchResponse, Error>) -> Void) {
        var components = URLComponents(string: "\(Constants.baseURL)/trending/movie/week")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: Constants.apiKey),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        performRequest(url: components.url!, completion: completion)
    }

    // MARK: - Movie Detail
    func fetchMovieDetail(id: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        var components = URLComponents(string: "\(Constants.baseURL)/movie/\(id)")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: Constants.apiKey)
        ]
        performRequest(url: components.url!, completion: completion)
    }

    // MARK: - Content Rating (US MPAA cert)
    func fetchContentRating(movieId: Int, completion: @escaping (String) -> Void) {
        var components = URLComponents(string: "\(Constants.baseURL)/movie/\(movieId)/release_dates")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: Constants.apiKey)
        ]

        guard let url = components.url else {
            completion("NR")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion("NR")
                return
            }

            do {
                let response = try JSONDecoder().decode(ReleaseDatesResponse.self, from: data)
                if let usEntry = response.results.first(where: { $0.iso31661 == "US" }),
                   let cert = usEntry.releaseDates.first(where: { !$0.certification.isEmpty })?.certification {
                    completion(cert)
                } else {
                    completion("NR")
                }
            } catch {
                completion("NR")
            }
        }.resume()
    }

    // MARK: - Image Download
    func downloadImage(url: URL, completion: @escaping (Data?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            completion(data)
        }.resume()
    }

    // MARK: - Private Helper
    private func performRequest<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - Release Dates Response Models
private struct ReleaseDatesResponse: Decodable {
    let results: [CountryRelease]
}

private struct CountryRelease: Decodable {
    let iso31661: String
    let releaseDates: [ReleaseDate]

    enum CodingKeys: String, CodingKey {
        case iso31661 = "iso_3166_1"
        case releaseDates = "release_dates"
    }
}

private struct ReleaseDate: Decodable {
    let certification: String
}

// MARK: - Errors
enum APIError: LocalizedError {
    case noData
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .noData: return "No data received from server."
        case .invalidURL: return "Invalid URL."
        }
    }
}
