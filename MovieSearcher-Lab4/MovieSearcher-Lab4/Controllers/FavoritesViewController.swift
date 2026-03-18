import SwiftUI

struct FavoritesView: View {
    @State private var favorites: [FavoriteMovie] = []

    var body: some View {
        Group {
            if favorites.isEmpty {
                VStack {
                    Spacer()
                    Text("No favorites yet.\nSearch for movies and add them!")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)
                    Spacer()
                }
            } else {
                List {
                    ForEach(favorites, id: \.id) { fav in
                        NavigationLink(destination: DetailView(
                            movieId: fav.id,
                            movie: Movie(
                                id: fav.id,
                                title: fav.title,
                                overview: "",
                                posterPath: fav.posterPath,
                                releaseDate: fav.releaseDate,
                                voteAverage: fav.voteAverage,
                                voteCount: 0,
                                adult: false
                            )
                        )) {
                            FavoriteRowView(favorite: fav)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            FavoritesStore.shared.removeFavorite(id: favorites[index].id)
                        }
                        favorites.remove(atOffsets: indexSet)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favorites")
        .onAppear {
            favorites = FavoritesStore.shared.favorites
        }
    }
}

#Preview("FavoritesView") {
    NavigationView { FavoritesView() }
}
