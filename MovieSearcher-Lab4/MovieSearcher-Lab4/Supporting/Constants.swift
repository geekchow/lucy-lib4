import Foundation

enum Constants {
    // MARK: - TMDb API
    static let apiKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "TMDbAPIKey") as? String,
              !key.isEmpty else {
            fatalError("TMDbAPIKey missing from Info.plist")
        }
        return key
    }()
    static let baseURL = "https://api.themoviedb.org/3"
    static let imageBaseURL = "https://image.tmdb.org/t/p/w500"

    // MARK: - UserDefaults Keys
    static let favoritesKey = "com.moviesearcher.favorites"
    static let searchHistoryKey = "com.moviesearcher.searchHistory"

    // MARK: - Layout
    static let collectionViewColumns: CGFloat = 3
    static let collectionViewSpacing: CGFloat = 8
    static let cellAspectRatio: CGFloat = 1.6
    static let maxSearchHistory = 5
}
