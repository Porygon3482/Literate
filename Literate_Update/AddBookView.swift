import SwiftUI

struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var author = ""
    @State private var bookDescription = ""
    @State private var isFavorite = false
    @State private var isRead = false

    let onSave: (Book) -> Void

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedAuthor: String {
        author.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedDescription: String {
        bookDescription.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Book Information") {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.words)

                    TextField("Author", text: $author)
                        .textInputAutocapitalization(.words)

                    TextField(
                        "Description or notes",
                        text: $bookDescription,
                        axis: .vertical
                    )
                    .lineLimit(3...7)
                }

                Section("Status") {
                    Toggle("Favorite", isOn: $isFavorite)
                    Toggle("Already read", isOn: $isRead)
                }

                Section {
                    Text("Books added here stay in My Library and are not placed on the public map.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBook()
                    }
                    .disabled(trimmedTitle.isEmpty)
                }
            }
        }
    }

    private func saveBook() {
        let newBook = Book(
            title: trimmedTitle,
            author: trimmedAuthor.isEmpty ? "Unknown Author" : trimmedAuthor,
            description: trimmedDescription,
            isFavorite: isFavorite,
            isRead: isRead,
            coverImageName: nil,
            location: nil
        )

        onSave(newBook)
        dismiss()
    }
}

#Preview {
    AddBookView { _ in }
}
