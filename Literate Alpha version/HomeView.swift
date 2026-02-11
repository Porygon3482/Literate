import SwiftUI
import MapKit

struct HomeView: View {
    @Binding var listings: [Book]
    @State private var position: MapCameraPosition = .automatic

    init(listings: Binding<[Book]>) {
        _listings = listings
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top listings strip
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(listings) { book in
                            NavigationLink(value: book) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Group {
                                        if let name = book.coverImageName, !name.isEmpty, UIImage(named: name) != nil {
                                            Image(name)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 90, height: 120)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.quaternary, lineWidth: 0.5))
                                        } else {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial)
                                                Image(systemName: "book.closed").font(.title3).foregroundStyle(.secondary)
                                            }
                                            .frame(width: 90, height: 120)
                                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.quaternary, lineWidth: 0.5))
                                        }
                                    }
                                    Text(book.title)
                                        .font(.caption)
                                        .lineLimit(2)
                                        .frame(width: 90, alignment: .leading)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(.bar)

                Divider()

                // Center map fills remaining space
                Map(position: $position) {
                    ForEach(listings.compactMap { $0.location != nil ? $0 : nil }, id: \.id) { book in
                        if let loc = book.location {
                            let coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
                            Annotation("", coordinate: coordinate) {
                                NavigationLink(value: book) {
                                    VStack(spacing: 4) {
                                        if let name = book.coverImageName, !name.isEmpty, UIImage(named: name) != nil {
                                            Image(name)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 36, height: 48)
                                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary, lineWidth: 0.5))
                                        } else {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 6).fill(.ultraThinMaterial)
                                                Image(systemName: "book.closed").foregroundStyle(.secondary)
                                            }
                                            .frame(width: 36, height: 48)
                                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary, lineWidth: 0.5))
                                        }
                                        Text(book.title)
                                            .font(.caption2)
                                            .lineLimit(1)
                                            .fixedSize()
                                            .padding(.horizontal, 4)
                                            .background(.thinMaterial, in: Capsule())
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    if let region = regionThatFits(books: listings) {
                        position = .region(region)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .navigationTitle("Home")
            .navigationDestination(for: Book.self) { book in
                BookDetailView(book: binding(for: book))
            }
        }
    }

    private func binding(for book: Book) -> Binding<Book> {
        guard let index = listings.firstIndex(where: { $0.id == book.id }) else {
            fatalError("Book not found")
        }
        return $listings[index]
    }

    private func regionThatFits(books: [Book]) -> MKCoordinateRegion? {
        let coords = books.compactMap { b -> CLLocationCoordinate2D? in
            guard let l = b.location else { return nil }
            return CLLocationCoordinate2D(latitude: l.latitude, longitude: l.longitude)
        }
        guard !coords.isEmpty else { return nil }

        var minLat = coords.first!.latitude
        var maxLat = coords.first!.latitude
        var minLon = coords.first!.longitude
        var maxLon = coords.first!.longitude

        for c in coords {
            minLat = min(minLat, c.latitude)
            maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude)
            maxLon = max(maxLon, c.longitude)
        }

        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2.0,
                                            longitude: (minLon + maxLon) / 2.0)
        let span = MKCoordinateSpan(latitudeDelta: max(0.02, (maxLat - minLat) * 1.5),
                                    longitudeDelta: max(0.02, (maxLon - minLon) * 1.5))
        return MKCoordinateRegion(center: center, span: span)
    }
}

#Preview {
    @Previewable @State var books = Library().books
    HomeView(listings: $books)
}
