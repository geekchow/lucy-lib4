import Foundation

struct MovieSearchResponse: Decodable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Movie: Decodable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let adult: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case adult
    }

    var fullPosterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: Constants.imageBaseURL + path)
    }

    var releaseYear: String {
        guard let date = releaseDate, date.count >= 4 else { return "N/A" }
        return String(date.prefix(4))
    }

    var scorePercent: String {
        let score = Int((voteAverage * 10).rounded())
        return "\(score)%"
    }

    var contentRatingFallback: String {
        return adult ? "R" : "PG-13"
    }
}
