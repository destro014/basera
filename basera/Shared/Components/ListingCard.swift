import SwiftUI
import VroxalDesign

struct ListingCard: View {
    enum FavoriteStyle {
        case none
        case subtle
        case prominent
    }

    let listing: Listing
    var isFavorite: Bool = false
    var favoriteStyle: FavoriteStyle = .subtle
    var onFavoriteTap: (() -> Void)?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: VdSpacing.none) {
                cardImage

                VStack(alignment: .leading, spacing: VdSpacing.sm) {
                    VStack(alignment: .leading, spacing: VdSpacing.xs) {
                        Text(primaryTitle)
                            .vdFont(VdFont.labelMedium)
                            .foregroundStyle(Color.vdContentDefaultBase)
                            .lineLimit(1)

                        Text(listing.approximateLocation)
                            .vdFont(VdFont.bodyMedium)
                            .foregroundStyle(Color.vdContentDefaultSecondary)
                            .lineLimit(1)
                    }

                    Text(formattedPrice)
                        .vdFont(VdFont.titleMedium)
                        .foregroundStyle(Color.vdContentDefaultBase)
                        .lineLimit(1)
                }
                .padding(.horizontal, VdSpacing.md)
                .padding(.vertical, VdSpacing.sm)
            }
            .frame(width: 230, alignment: .leading)
            .background(Color.vdBackgroundDefaultSecondary)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: VdRadius.md,
                    style: .continuous
                )
            )

            if favoriteStyle != .none {
                Button {
                    onFavoriteTap?()
                } label: {
                    Image(systemName: favoriteSymbol)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(favoriteForegroundColor)
                        .frame(width: 24, height: 24)
                        .padding(4)
                        .background(favoriteBackgroundColor)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: VdRadius.sm,
                                style: .continuous
                            )
                        )
                }
                .buttonStyle(.plain)
                .disabled(onFavoriteTap == nil)
                .padding(VdSpacing.sm)
            }
        }
    }

    private var cardImage: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.vdBackgroundPrimarySecondary.opacity(0.80),
                    Color.vdBackgroundDefaultSecondary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: listing.media.first?.systemImageName ?? "photo")
                .font(.system(size: 40, weight: .regular))
                .foregroundStyle(Color.vdContentDefaultSecondary.opacity(0.5))
        }
        .frame(height: 148)
        .frame(maxWidth: .infinity)
    }

    private var primaryTitle: String {
        "\(listing.bedroomCount)BHK \(listing.propertyType.rawValue)"
    }

    private var formattedPrice: String {
        "NPR. \(listing.monthlyRent.formatted(.number))"
    }

    private var favoriteSymbol: String {
        switch favoriteStyle {
        case .none:
            "heart"
        case .subtle:
            isFavorite ? "heart.fill" : "heart"
        case .prominent:
            "heart.fill"
        }
    }

    private var favoriteBackgroundColor: Color {
        switch favoriteStyle {
        case .none:
            .clear
        case .subtle:
            Color.vdBackgroundPrimarySecondary
        case .prominent:
            Color.vdBackgroundPrimaryBase
        }
    }

    private var favoriteForegroundColor: Color {
        switch favoriteStyle {
        case .none:
            Color.vdContentDefaultSecondary
        case .subtle:
            Color.vdContentPrimaryBase
        case .prominent:
            .white
        }
    }
}

#Preview("Default") {
    ListingCard(listing: PreviewData.featuredListings[0])
        .padding()
        .background(Color.vdBackgroundDefaultBase)
}

#Preview("Favourite") {
    ListingCard(
        listing: PreviewData.featuredListings[2],
        isFavorite: true,
        favoriteStyle: .prominent,
        onFavoriteTap: {}
    )
    .padding()
    .background(Color.vdBackgroundDefaultBase)
}
