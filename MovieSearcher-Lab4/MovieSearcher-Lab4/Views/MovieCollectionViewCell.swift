import SwiftUI
import UIKit

struct CachedAsyncImage: View {
    let urlString: String?
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color(.systemGray5)
                    .overlay(
                        Image(systemName: "film")
                            .foregroundColor(.gray)
                    )
            }
        }
        .onAppear(perform: load)
        .onChange(of: urlString) { _ in
            image = nil
            load()
        }
    }

    private func load() {
        guard let urlString = urlString else { return }
        if let cached = ImageCache.shared.cachedImage(for: urlString) {
            image = cached
            return
        }
        ImageCache.shared.loadImage(from: urlString) { img in
            DispatchQueue.main.async { image = img }
        }
    }
}

struct MovieCardView: View {
    let movie: Movie

    var body: some View {
        VStack(spacing: 4) {
            CachedAsyncImage(urlString: movie.fullPosterURL?.absoluteString)
                .aspectRatio(2.0 / 3.0, contentMode: .fill)
                .cornerRadius(4)
                .clipped()
            Text(movie.title)
                .font(.system(size: 11, weight: .medium))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
    }
}
