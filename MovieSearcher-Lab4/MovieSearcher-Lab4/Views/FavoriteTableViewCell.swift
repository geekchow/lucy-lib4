import SwiftUI

struct FavoriteRowView: View {
    let favorite: FavoriteMovie

    var body: some View {
        HStack(spacing: 12) {
            CachedAsyncImage(urlString: favorite.fullPosterURL?.absoluteString)
                .frame(width: 60, height: 90)
                .cornerRadius(4)
                .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(favorite.title)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(2)
                Text(favorite.releaseYear)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Text("Score: \(favorite.scorePercent)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(favorite.contentRating)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(width: 44, height: 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.secondary, lineWidth: 1)
                )
        }
        .padding(.vertical, 4)
    }
}
