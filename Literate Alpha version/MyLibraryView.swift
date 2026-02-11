import SwiftUI

struct MyLibraryView: View {
    @Binding var books: [Book]
    @State private var searchText: String = ""

    private var filtered: [Book] {
        guard !searchText.isEmpty else { return books }
        return books.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.author.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List {
            ForEach(filtered) { book in
                NavigationLink(value: book) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.title).font(.headline)
                        Text(book.author).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete(perform: delete)
        }
        .searchable(text: $searchText)
        .toolbar { EditButton() }
        .navigationTitle("My Library")
        .navigationDestination(for: Book.self) { book in
            if let idx = books.firstIndex(where: { $0.id == book.id }) {
                BookDetailView(book: $books[idx])
            } else {
                // Fallback to a local copy if binding fails
                @State var local = book
                BookDetailView(book: $local)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        books.remove(atOffsets: offsets)
    }
}

#Preview {
    @Previewable @State var mine: [Book] = [
        Book(title: "My Book 1", author: "Me", description: ""),
        Book(title: "My Book 2", author: "Me", description: "")
    ]
    NavigationStack { MyLibraryView(books: $mine) }
}
