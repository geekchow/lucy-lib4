import Foundation

struct FavoriteMovie: Codable, Equatable {
    let id: Int
    let title: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let contentRating: String

    init(from movie: Movie, contentRating: String) {
        self.id = movie.id
        self.title = movie.title
        self.posterPath = movie.posterPath
        self.releaseDate = movie.releaseDate
        self.voteAverage = movie.voteAverage
        self.contentRating = contentRating
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
}
