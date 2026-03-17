import Foundation

struct SearchHistoryEntry: Codable {
    let query: String
    let date: Date
}

class FavoritesStore {
    static let shared = FavoritesStore()
    private init() {
        loadFavorites()
        loadSearchHistory()
    }

    private(set) var favorites: [FavoriteMovie] = []
    private(set) var searchHistory: [SearchHistoryEntry] = []

    private let defaults = UserDefaults.standard

    // MARK: - Favorites
    private func loadFavorites() {
        guard let data = defaults.data(forKey: Constants.favoritesKey) else {
            favorites = []
            return
        }
        favorites = (try? JSONDecoder().decode([FavoriteMovie].self, from: data)) ?? []
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            defaults.set(data, forKey: Constants.favoritesKey)
        }
    }

    func addFavorite(_ favorite: FavoriteMovie) {
        guard !isFavorite(id: favorite.id) else { return }
        favorites.append(favorite)
        saveFavorites()
    }

    func removeFavorite(id: Int) {
        favorites.removeAll { $0.id == id }
        saveFavorites()
    }

    func isFavorite(id: Int) -> Bool {
        return favorites.contains { $0.id == id }
    }

    // MARK: - Search History
    private func loadSearchHistory() {
        guard let data = defaults.data(forKey: Constants.searchHistoryKey) else {
            searchHistory = []
            return
        }
        searchHistory = (try? JSONDecoder().decode([SearchHistoryEntry].self, from: data)) ?? []
    }

    private func saveSearchHistory() {
        if let data = try? JSONEncoder().encode(searchHistory) {
            defaults.set(data, forKey: Constants.searchHistoryKey)
        }
    }

    func addSearchHistory(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        // Remove existing duplicate (case-insensitive)
        searchHistory.removeAll { $0.query.lowercased() == trimmed.lowercased() }

        // Insert at front
        searchHistory.insert(SearchHistoryEntry(query: trimmed, date: Date()), at: 0)

        // Keep max 5
        if searchHistory.count > Constants.maxSearchHistory {
            searchHistory = Array(searchHistory.prefix(Constants.maxSearchHistory))
        }

        saveSearchHistory()
    }

    func clearSearchHistory() {
        searchHistory = []
        saveSearchHistory()
    }
}
