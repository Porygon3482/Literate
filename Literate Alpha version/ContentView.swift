import SwiftUI
import MapKit
import CoreLocation
import UIKit

struct BookLocation: Hashable, Codable {
    var latitude: Double
    var longitude: Double
}

struct Book: Identifiable, Hashable {
    let id: UUID
    var title: String
    var author: String
    var description: String
    var isFavorite: Bool
    var isRead: Bool
    var coverImageName: String?
    var location: BookLocation?

    init(id: UUID = UUID(), title: String, author: String, description: String, isFavorite: Bool = false, isRead: Bool = false, coverImageName: String? = nil, location: BookLocation? = nil) {
        self.id = id
        self.title = title
        self.author = author
        self.description = description
        self.isFavorite = isFavorite
        self.isRead = isRead
        self.coverImageName = coverImageName
        self.location = location
    }
}

@Observable
final class Library {
    var books: [Book] = [
        Book(title: "The Swift Programming Language", author: "Apple Inc.", description: "A comprehensive guide to Swift, Apple's powerful and intuitive programming language.", coverImageName: "swift", location: BookLocation(latitude: 37.3349, longitude: -122.0090)),
        Book(title: "Clean Code", author: "Robert C. Martin", description: "A handbook of agile software craftsmanship with principles, patterns, and best practices.", coverImageName: "clean-code", location: BookLocation(latitude: 41.8781, longitude: -87.6298)),
        Book(title: "Design Patterns", author: "Erich Gamma et al.", description: "Elements of reusable object-oriented software with classic design patterns.", coverImageName: "design-patterns", location: BookLocation(latitude: 47.6062, longitude: -122.3321)),
        Book(title: "The Pragmatic Programmer", author: "Andrew Hunt & David Thomas", description: "Journey to mastery with practical tips for effective software development.", coverImageName: "pragmatic-programmer", location: BookLocation(latitude: 30.2672, longitude: -97.7431)),
        Book(title: "Introduction to Algorithms", author: "Cormen, Leiserson, Rivest, Stein", description: "Foundational algorithms and data structures with rigorous analysis.", coverImageName: "clrs", location: BookLocation(latitude: 42.3601, longitude: -71.0942))
    ]
}

struct ContentView: View {
    @State private var library = Library()
    @State private var searchText: String = ""
    @State private var showOnlyFavorites: Bool = false

    var filteredBooks: [Book] {
        var list = library.books
        if showOnlyFavorites {
            list = list.filter { $0.isFavorite }
        }
        if !searchText.isEmpty {
            list = list.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.author.localizedCaseInsensitiveContains(searchText) }
        }
        return list
    }

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(listings: $library.books)
            }
            .tabItem { Label("Home", systemImage: "house") }

            NavigationStack {
                List {
                    ForEach(filteredBooks) { book in
                        NavigationLink(value: book) {
                            HStack(alignment: .top, spacing: 12) {
                                Group {
                                    if let name = book.coverImageName, !name.isEmpty, UIImage(named: name) != nil {
                                        Image(name)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 48, height: 64)
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(.quaternary, lineWidth: 0.5)
                                            )
                                    } else {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(.ultraThinMaterial)
                                            Image(systemName: "book.closed")
                                                .foregroundStyle(.secondary)
                                        }
                                        .frame(width: 48, height: 64)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(.quaternary, lineWidth: 0.5)
                                        )
                                    }
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(book.title)
                                            .font(.headline)
                                            .lineLimit(2)
                                        if book.isFavorite {
                                            Image(systemName: "heart.fill").foregroundStyle(.pink)
                                        }
                                        if book.isRead {
                                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                        }
                                    }
                                    Text(book.author)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                delete(book)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                toggleFavorite(book)
                            } label: {
                                Label(book.isFavorite ? "Unfavorite" : "Favorite", systemImage: book.isFavorite ? "heart.slash" : "heart")
                            }.tint(.pink)

                            Button {
                                toggleRead(book)
                            } label: {
                                Label(book.isRead ? "Mark Unread" : "Mark Read", systemImage: book.isRead ? "book.closed" : "book")
                            }.tint(.green)
                        }
                    }
                }
                .navigationTitle("Library")
                .navigationDestination(for: Book.self) { book in
                    BookDetailView(book: binding(for: book))
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Toggle(isOn: $showOnlyFavorites) {
                                Label("Show Favorites Only", systemImage: "heart")
                            }
                            Button {
                                addSampleBook()
                            } label: {
                                Label("Add Sample Book", systemImage: "plus")
                            }
                            NavigationLink {
                                LibraryMapView()
                            } label: {
                                Label("View Map", systemImage: "map")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .tabItem { Label("Library", systemImage: "list.bullet") }
        }
    }

    private func binding(for book: Book) -> Binding<Book> {
        guard let index = library.books.firstIndex(where: { $0.id == book.id }) else {
            fatalError("Book not found")
        }
        return $library.books[index]
    }

    private func toggleFavorite(_ book: Book) {
        if let idx = library.books.firstIndex(where: { $0.id == book.id }) {
            library.books[idx].isFavorite.toggle()
        }
    }

    private func toggleRead(_ book: Book) {
        if let idx = library.books.firstIndex(where: { $0.id == book.id }) {
            library.books[idx].isRead.toggle()
        }
    }

    private func delete(_ book: Book) {
        if let idx = library.books.firstIndex(where: { $0.id == book.id }) {
            withAnimation { library.books.remove(at: idx) }
        }
    }

    private func addSampleBook() {
        withAnimation {
            library.books.insert(
                Book(title: "New Book", author: "Unknown Author", description: "A newly added sample book for demonstration.", coverImageName: nil, location: nil),
                at: 0
            )
        }
    }
}

#Preview {
    ContentView()
}

