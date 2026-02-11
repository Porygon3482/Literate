import SwiftUI
import MapKit

struct ListingAnnotation: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
}

struct ListingsView: View {
    @Binding var listings: [Book]
    @State private var searchText: String = ""
    @State private var showingMap = false

    private var filtered: [Book] {
        guard !searchText.isEmpty else { return listings }
        return listings.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.author.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List {
            ForEach(filtered) { book in
                NavigationLink(value: book) {
                    HStack(spacing: 12) {
                        Group {
                            if let name = book.coverImageName, !name.isEmpty, UIImage(named: name) != nil {
                                Image(name)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 48, height: 64)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary, lineWidth: 0.5))
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6).fill(.ultraThinMaterial)
                                    Image(systemName: "book.closed").foregroundStyle(.secondary)
                                }
                                .frame(width: 48, height: 64)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary, lineWidth: 0.5))
                            }
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.title).font(.headline).lineLimit(2)
                            Text(book.author).font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Listings")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingMap = true
                } label: {
                    Label("Map", systemImage: "map")
                }
            }
        }
        .sheet(isPresented: $showingMap) {
            // Build annotations only if you have coordinates from another source.
            // Currently, Book has no latitude/longitude, so we present an empty map.
            MapView(annotations: [])
        }
        .navigationDestination(for: Book.self) { book in
            // Use a local copy for now since we don't have bindings here
            @State var local = book
            BookDetailView(book: $local)
        }
    }
}

struct MapView: View {
    var annotations: [ListingAnnotation]
    @Environment(\.dismiss) var dismiss
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
    )

    var body: some View {
        NavigationStack {
            Map(coordinateRegion: $region, annotationItems: annotations) { item in
                MapMarker(coordinate: item.coordinate, tint: .blue)
            }
            .navigationTitle("Map")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var listings: [Book] = [
        Book(title: "Item 1", author: "Seller A", description: ""),
        Book(title: "Item 2", author: "Seller B", description: "")
    ]
    NavigationStack { ListingsView(listings: $listings) }
}
