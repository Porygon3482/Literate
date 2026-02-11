import SwiftUI
import MapKit

// MARK: - Models used by this view
// A lightweight model for a public listing that includes location.
struct Listing: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
}

extension Listing: Equatable {
    static func == (lhs: Listing, rhs: Listing) -> Bool {
        lhs.id == rhs.id
    }
}

extension Listing: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Local placeholder to avoid clashing with any global Book type.
struct UserBook: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let author: String
}

// MARK: - View
struct LibraryMapView: View {
    enum Section: String, CaseIterable, Identifiable {
        case listings = "Listings"
        case library = "My Library"
        var id: String { rawValue }
    }

    @State private var selectedSection: Section = .listings

    // Map region state
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    // Sample data for listings (with coordinates) and personal library (no coordinates)
    @State private var listings: [Listing] = [
        Listing(title: "The Pragmatic Programmer", subtitle: "Gently used", coordinate: .init(latitude: 37.776, longitude: -122.418)),
        Listing(title: "Clean Code", subtitle: "Like new", coordinate: .init(latitude: 37.771, longitude: -122.425))
    ]

    @State private var myLibrary: [UserBook] = [
        UserBook(title: "Introduction to Algorithms", author: "Cormen"),
        UserBook(title: "Design Patterns", author: "Gamma et al.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Picker("Section", selection: $selectedSection) {
                ForEach(Section.allCases) { section in
                    Text(section.rawValue).tag(section)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // Main content switches between Listings (map) and My Library (list)
            Group {
                switch selectedSection {
                case .listings:
                    listingsMap
                case .library:
                    libraryList
                }
            }
            .animation(.default, value: selectedSection)
        }
        .navigationTitle(selectedSection.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Listings Map
    private var listingsMap: some View {
        Map(
            coordinateRegion: $region,
            annotationItems: listings
        ) { item in
            MapMarker(coordinate: item.coordinate, tint: .blue)
        }
        .ignoresSafeArea(edges: .bottom)
        .overlay(alignment: .topLeading) {
            // A small legend overlay for context
            VStack(alignment: .leading, spacing: 8) {
                Label("Used Book Listings", systemImage: "mappin")
                    .font(.headline)
                    .padding(8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
            .padding()
        }
    }

    // MARK: My Library List
    private var libraryList: some View {
        List(myLibrary) { book in
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    NavigationStack {
        LibraryMapView()
    }
}

