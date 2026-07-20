import SwiftUI
import MapKit
import UIKit

struct HomeView: View {
    @Binding var listings: [Book]
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        VStack(spacing: 0) {
            listingsStrip

            Divider()

            listingsMap
        }
        .navigationTitle("Available Books")
        .navigationDestination(for: Book.self) { book in
            BookDetailView(book: binding(for: book))
        }
        .onAppear {
            if let region = regionThatFits(books: listings) {
                position = .region(region)
            }
        }
    }

    private var listingsStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(listings) { book in
                    NavigationLink(value: book) {
                        VStack(alignment: .leading, spacing: 6) {
                            bookCover(for: book)
                                .frame(width: 90, height: 120)

                            Text(book.title)
                                .font(.caption)
                                .lineLimit(2)
                                .frame(width: 90, alignment: .leading)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(.bar)
    }

    private var listingsMap: some View {
        Map(position: $position) {
            ForEach(listings.filter { $0.location != nil }) { book in
                if let location = book.location {
                    let coordinate = CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )

                    Annotation(book.title, coordinate: coordinate) {
                        NavigationLink(value: book) {
                            VStack(spacing: 4) {
                                bookCover(for: book)
                                    .frame(width: 36, height: 48)

                                Text(book.title)
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .fixedSize()
                                    .padding(.horizontal, 4)
                                    .background(.thinMaterial, in: Capsule())
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .overlay {
            if listings.allSatisfy({ $0.location == nil }) {
                ContentUnavailableView(
                    "No Public Listings",
                    systemImage: "map",
                    description: Text("Books in My Library do not appear on this map.")
                )
            }
        }
    }

    @ViewBuilder
    private func bookCover(for book: Book) -> some View {
        Group {
            if let name = book.coverImageName,
               !name.isEmpty,
               UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)

                    Image(systemName: "book.closed")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.quaternary, lineWidth: 0.5)
        }
    }

    private func binding(for book: Book) -> Binding<Book> {
        guard let index = listings.firstIndex(where: { $0.id == book.id }) else {
            fatalError("Listing not found")
        }

        return $listings[index]
    }

    private func regionThatFits(books: [Book]) -> MKCoordinateRegion? {
        let coordinates = books.compactMap { book -> CLLocationCoordinate2D? in
            guard let location = book.location else {
                return nil
            }

            return CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )
        }

        guard let first = coordinates.first else {
            return nil
        }

        var minLatitude = first.latitude
        var maxLatitude = first.latitude
        var minLongitude = first.longitude
        var maxLongitude = first.longitude

        for coordinate in coordinates {
            minLatitude = min(minLatitude, coordinate.latitude)
            maxLatitude = max(maxLatitude, coordinate.latitude)
            minLongitude = min(minLongitude, coordinate.longitude)
            maxLongitude = max(maxLongitude, coordinate.longitude)
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLatitude + maxLatitude) / 2,
            longitude: (minLongitude + maxLongitude) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: max(0.02, (maxLatitude - minLatitude) * 1.5),
            longitudeDelta: max(0.02, (maxLongitude - minLongitude) * 1.5)
        )

        return MKCoordinateRegion(center: center, span: span)
    }
}

#Preview {
    @Previewable @State var listings = Library().listings

    NavigationStack {
        HomeView(listings: $listings)
    }
}
