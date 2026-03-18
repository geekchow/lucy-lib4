import SwiftUI
import UIKit

struct DetailView: View {
    let movieId: Int
    let movie: Movie

    @State private var contentRating: String = "..."
    @State private var isFavorite: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                CachedAsyncImage(urlString: movie.fullPosterURL?.absoluteString)
                    .frame(maxWidth: .infinity)
                    .frame(height: min(UIScreen.main.bounds.width * 1.5, 400))
                    .clipped()

                VStack(spacing: 6) {
                    Text(movie.title)
                        .font(.system(size: 22, weight: .bold))
                        .multilineTextAlignment(.center)
                    Text("Released: \(movie.releaseYear)")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                    Text("Score: \(movie.scorePercent)")
                        .font(.system(size: 15))
                    Text("Rating: \(contentRating)")
                        .font(.system(size: 15))
                }
                .padding(.horizontal, 16)

                Text(movie.overview)
                    .font(.system(size: 14))
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: toggleFavorite) {
                    Label(
                        isFavorite ? "Remove from Favorites" : "Add to Favorites",
                        systemImage: isFavorite ? "heart.slash.fill" : "heart.fill"
                    )
                    .frame(width: 240, height: 48)
                }
                .buttonStyle(.borderedProminent)
                .tint(isFavorite ? .red : .blue)
                .padding(.bottom, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: "Check out \(movie.title) on TMDb!")
            }
        }
        .onAppear {
            isFavorite = FavoritesStore.shared.isFavorite(id: movieId)
            fetchContentRating()
        }
    }

    private func fetchContentRating() {
        MovieAPIService.shared.fetchContentRating(movieId: movieId) { cert in
            DispatchQueue.main.async {
                contentRating = cert
            }
        }
    }

    private func toggleFavorite() {
        if isFavorite {
            FavoritesStore.shared.removeFavorite(id: movieId)
            isFavorite = false
        } else {
            let rating = contentRating == "..." ? movie.contentRatingFallback : contentRating
            let favorite = FavoriteMovie(from: movie, contentRating: rating)
            FavoritesStore.shared.addFavorite(favorite)
            isFavorite = true
        }
    }
}

#Preview("DetailView") {
    let movie = Movie(
        id: 550, title: "Fight Club",
        overview: "An insomniac office worker and a soap salesman form an underground fight club.",
        posterPath: Optional<String>.none, releaseDate: "1999-10-15",
        voteAverage: 8.4, voteCount: 24000, adult: false
    )
    NavigationView {
        DetailView(movieId: movie.id, movie: movie)
    }
}
