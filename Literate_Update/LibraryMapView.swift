import SwiftUI
import MapKit

// Optional standalone map view for public listings.
// Personal library books should never be passed into this view.
struct LibraryMapView: View {
    let listings: [Book]
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $position) {
            ForEach(listings.filter { $0.location != nil }) { book in
                if let location = book.location {
                    Annotation(
                        book.title,
                        coordinate: CLLocationCoordinate2D(
                            latitude: location.latitude,
                            longitude: location.longitude
                        )
                    ) {
                        VStack(spacing: 4) {
                            Image(systemName: "book.closed.fill")
                                .padding(8)
                                .background(.thinMaterial, in: Circle())

                            Text(book.title)
                                .font(.caption2)
                                .lineLimit(1)
                                .padding(.horizontal, 5)
                                .background(.thinMaterial, in: Capsule())
                        }
                    }
                }
            }
        }
        .navigationTitle("Public Listings")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if listings.allSatisfy({ $0.location == nil }) {
                ContentUnavailableView(
                    "No Public Listings",
                    systemImage: "map",
                    description: Text("Personal library books are not shown here.")
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        LibraryMapView(listings: Library().listings)
    }
}
