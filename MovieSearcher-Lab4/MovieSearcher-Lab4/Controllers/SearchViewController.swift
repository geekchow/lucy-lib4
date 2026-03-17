import SwiftUI

enum SortOption: String, CaseIterable {
    case defaultOrder = "Default Order"
    case titleAZ = "Title A–Z"
    case highestRated = "Highest Rated"
    case newestFirst = "Newest First"
}

struct SearchView: View {
    @State private var movies: [Movie] = []
    @State private var filteredMovies: [Movie] = []
    @State private var searchText: String = ""
    @State private var currentQuery: String = ""
    @State private var isLoading: Bool = false
    @State private var isLoadingPage: Bool = false
    @State private var isTrending: Bool = true
    @State private var currentPage: Int = 1
    @State private var totalPages: Int = 1
    @State private var currentSort: SortOption = .defaultOrder
    @State private var showSortSheet: Bool = false
    @State private var searchHistory: [SearchHistoryEntry] = []

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: Constants.collectionViewSpacing),
        count: 3
    )

    var body: some View {
        ScrollView {
            if isLoading && movies.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
            } else {
                LazyVGrid(columns: columns, spacing: Constants.collectionViewSpacing) {
                    ForEach(filteredMovies, id: \.id) { movie in
                        NavigationLink(destination: DetailView(movieId: movie.id, movie: movie)) {
                            MovieCardView(movie: movie)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button {
                                toggleFavorite(movie: movie)
                            } label: {
                                let isFav = FavoritesStore.shared.isFavorite(id: movie.id)
                                Label(
                                    isFav ? "Remove from Favorites" : "Add to Favorites",
                                    systemImage: isFav ? "heart.slash" : "heart"
                                )
                            }
                            ShareLink(item: "Check out \(movie.title) on TMDb!")
                        }
                        .onAppear {
                            if movie.id == filteredMovies.last?.id {
                                loadNextPage()
                            }
                        }
                    }
                }
                .padding(Constants.collectionViewSpacing)

                if isLoadingPage {
                    ProgressView()
                        .padding()
                }

                Text("Powered by TMDb")
                    .font(.system(size: 11))
                    .foregroundColor(Color(.tertiaryLabel))
                    .padding(.bottom, 8)
            }
        }
        .navigationTitle("Movies")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSortSheet = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search movies…")
        .searchSuggestions {
            ForEach(searchHistory, id: \.query) { entry in
                Label(entry.query, systemImage: "clock")
                    .searchCompletion(entry.query)
            }
            if !searchHistory.isEmpty {
                Button("Clear History") {
                    FavoritesStore.shared.clearSearchHistory()
                    searchHistory = []
                }
            }
        }
        .onSubmit(of: .search) {
            performSearch()
        }
        .confirmationDialog("Sort By", isPresented: $showSortSheet) {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button(option.rawValue) {
                    currentSort = option
                    applySort()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            searchHistory = FavoritesStore.shared.searchHistory
            if movies.isEmpty {
                fetchTrending()
            }
        }
    }

    // MARK: - Search

    private func performSearch() {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }
        currentQuery = query
        isTrending = false
        movies = []
        currentPage = 1
        isLoading = true
        FavoritesStore.shared.addSearchHistory(query: query)
        searchHistory = FavoritesStore.shared.searchHistory

        MovieAPIService.shared.searchMovies(query: query, page: 1) { result in
            DispatchQueue.main.async {
                isLoading = false
                if case .success(let response) = result {
                    totalPages = response.totalPages
                    movies = response.results
                    applySort()
                }
            }
        }
    }

    // MARK: - Network

    private func fetchTrending() {
        isLoading = true
        isTrending = true
        MovieAPIService.shared.fetchTrending(page: 1) { result in
            DispatchQueue.main.async {
                isLoading = false
                if case .success(let response) = result {
                    movies = response.results
                    totalPages = response.totalPages
                    currentPage = 1
                    applySort()
                }
            }
        }
    }

    private func loadNextPage() {
        guard !isLoadingPage, !isLoading, currentPage < totalPages else { return }
        let nextPage = currentPage + 1
        isLoadingPage = true
        if isTrending {
            MovieAPIService.shared.fetchTrending(page: nextPage) { result in
                DispatchQueue.main.async {
                    isLoadingPage = false
                    if case .success(let response) = result {
                        movies.append(contentsOf: response.results)
                        currentPage = nextPage
                        applySort()
                    }
                }
            }
        } else {
            MovieAPIService.shared.searchMovies(query: currentQuery, page: nextPage) { result in
                DispatchQueue.main.async {
                    isLoadingPage = false
                    if case .success(let response) = result {
                        movies.append(contentsOf: response.results)
                        currentPage = nextPage
                        applySort()
                    }
                }
            }
        }
    }

    // MARK: - Sort

    private func applySort() {
        switch currentSort {
        case .defaultOrder:
            filteredMovies = movies
        case .titleAZ:
            filteredMovies = movies.sorted { $0.title < $1.title }
        case .highestRated:
            filteredMovies = movies.sorted { $0.voteAverage > $1.voteAverage }
        case .newestFirst:
            filteredMovies = movies.sorted { ($0.releaseDate ?? "") > ($1.releaseDate ?? "") }
        }
    }

    // MARK: - Favorites

    private func toggleFavorite(movie: Movie) {
        if FavoritesStore.shared.isFavorite(id: movie.id) {
            FavoritesStore.shared.removeFavorite(id: movie.id)
        } else {
            MovieAPIService.shared.fetchContentRating(movieId: movie.id) { cert in
                let favorite = FavoriteMovie(from: movie, contentRating: cert)
                DispatchQueue.main.async {
                    FavoritesStore.shared.addFavorite(favorite)
                }
            }
        }
    }
}
