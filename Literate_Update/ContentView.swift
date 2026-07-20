import SwiftUI
import MapKit
import CoreLocation
import UIKit
import Observation

struct BookLocation: Hashable, Codable {
    var latitude: Double
    var longitude: Double
}

struct Book: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var author: String
    var description: String
    var isFavorite: Bool
    var isRead: Bool
    var coverImageName: String?
    var location: BookLocation?

    init(
        id: UUID = UUID(),
        title: String,
        author: String,
        description: String,
        isFavorite: Bool = false,
        isRead: Bool = false,
        coverImageName: String? = nil,
        location: BookLocation? = nil
    ) {
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
    private static let myBooksStorageKey = "literate.myBooks"

    // These are public listings from other users. Only these appear on the map.
    var listings: [Book] = [
        Book(
            title: "The Swift Programming Language",
            author: "Apple Inc.",
            description: "A comprehensive guide to Swift.",
            coverImageName: "swift",
            location: BookLocation(latitude: 37.3349, longitude: -122.0090)
        ),
        Book(
            title: "Clean Code",
            author: "Robert C. Martin",
            description: "A handbook of agile software craftsmanship.",
            coverImageName: "clean-code",
            location: BookLocation(latitude: 37.3382, longitude: -121.8863)
        ),
        Book(
            title: "The Pragmatic Programmer",
            author: "Andrew Hunt & David Thomas",
            description: "Practical advice for effective software development.",
            coverImageName: "pragmatic-programmer",
            location: BookLocation(latitude: 37.3688, longitude: -122.0363)
        )
    ]

    // These are the signed-in user's personal library books.
    // They are stored locally and never appear on the map.
    var myBooks: [Book] {
        didSet {
            saveMyBooks()
        }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.myBooksStorageKey),
           let savedBooks = try? JSONDecoder().decode([Book].self, from: data) {
            myBooks = savedBooks
        } else {
            myBooks = []
        }
    }

    private func saveMyBooks() {
        guard let data = try? JSONEncoder().encode(myBooks) else {
            return
        }

        UserDefaults.standard.set(data, forKey: Self.myBooksStorageKey)
    }
}

struct ContentView: View {
    @State private var library = Library()
    @State private var searchText = ""
    @State private var showOnlyFavorites = false
    @State private var showingAddBook = false

    private var filteredBooks: [Book] {
        var books = library.myBooks

        if showOnlyFavorites {
            books = books.filter(\.isFavorite)
        }

        if !searchText.isEmpty {
            books = books.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.author.localizedCaseInsensitiveContains(searchText)
            }
        }

        return books
    }

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(listings: $library.listings)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationStack {
                libraryList
                    .navigationTitle("My Library")
                    .navigationDestination(for: Book.self) { book in
                        BookDetailView(book: binding(for: book))
                    }
                    .searchable(
                        text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .automatic)
                    )
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Menu {
                                Toggle(isOn: $showOnlyFavorites) {
                                    Label(
                                        "Show Favorites Only",
                                        systemImage: "heart"
                                    )
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                            }
                        }

                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showingAddBook = true
                            } label: {
                                Image(systemName: "plus")
                            }
                            .accessibilityLabel("Add Book")
                        }
                    }
                    .sheet(isPresented: $showingAddBook) {
                        AddBookView { newBook in
                            withAnimation {
                                library.myBooks.insert(newBook, at: 0)
                            }
                        }
                    }
            }
            .tabItem {
                Label("Library", systemImage: "books.vertical")
            }
        }
    }

    private var libraryList: some View {
        List {
            ForEach(filteredBooks) { book in
                NavigationLink(value: book) {
                    bookRow(book)
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
                        Label(
                            book.isFavorite ? "Unfavorite" : "Favorite",
                            systemImage: book.isFavorite ? "heart.slash" : "heart"
                        )
                    }
                    .tint(.pink)

                    Button {
                        toggleRead(book)
                    } label: {
                        Label(
                            book.isRead ? "Mark Unread" : "Mark Read",
                            systemImage: book.isRead ? "book.closed" : "book"
                        )
                    }
                    .tint(.green)
                }
            }
        }
        .overlay {
            if filteredBooks.isEmpty {
                ContentUnavailableView {
                    Label(
                        searchText.isEmpty ? "Your Library Is Empty" : "No Books Found",
                        systemImage: "books.vertical"
                    )
                } description: {
                    Text(
                        searchText.isEmpty
                        ? "Press the + button to add your first book."
                        : "Try a different title or author."
                    )
                } actions: {
                    if searchText.isEmpty {
                        Button("Add Book") {
                            showingAddBook = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func bookRow(_ book: Book) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Group {
                if let name = book.coverImageName,
                   !name.isEmpty,
                   UIImage(named: name) != nil {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.ultraThinMaterial)

                        Image(systemName: "book.closed")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(width: 48, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.quaternary, lineWidth: 0.5)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(book.title)
                        .font(.headline)
                        .lineLimit(2)

                    if book.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.pink)
                    }

                    if book.isRead {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
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

    private func binding(for book: Book) -> Binding<Book> {
        guard let index = library.myBooks.firstIndex(where: { $0.id == book.id }) else {
            fatalError("Book not found in My Library")
        }

        return $library.myBooks[index]
    }

    private func toggleFavorite(_ book: Book) {
        guard let index = library.myBooks.firstIndex(where: { $0.id == book.id }) else {
            return
        }

        library.myBooks[index].isFavorite.toggle()
    }

    private func toggleRead(_ book: Book) {
        guard let index = library.myBooks.firstIndex(where: { $0.id == book.id }) else {
            return
        }

        library.myBooks[index].isRead.toggle()
    }

    private func delete(_ book: Book) {
        guard let index = library.myBooks.firstIndex(where: { $0.id == book.id }) else {
            return
        }

        withAnimation {
            library.myBooks.remove(at: index)
        }
    }
}

#Preview {
    ContentView()
}
