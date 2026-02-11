import SwiftUI

struct BookDetailView: View {
    @Binding var book: Book
    @State private var showShareSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Group {
                        if let name = book.coverImageName, !name.isEmpty, UIImage(named: name) != nil {
                            Image(name)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 220)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.quaternary, lineWidth: 0.5)
                                )
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                                Image(systemName: "book.closed")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(height: 220)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.quaternary, lineWidth: 0.5)
                            )
                        }
                    }

                    Text(book.title)
                        .font(.title2)
                        .bold()
                    Text(book.author)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    Label(book.isFavorite ? "Favorited" : "Favorite", systemImage: book.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(book.isFavorite ? .pink : .secondary)
                    Label(book.isRead ? "Read" : "Unread", systemImage: book.isRead ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(book.isRead ? .green : .secondary)
                }
                .font(.subheadline)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    Text(book.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Divider()

                HStack(spacing: 12) {
                    Button {
                        book.isFavorite.toggle()
                    } label: {
                        Label(book.isFavorite ? "Unfavorite" : "Favorite", systemImage: book.isFavorite ? "heart.slash" : "heart")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.pink)

                    Button {
                        book.isRead.toggle()
                    } label: {
                        Label(book.isRead ? "Mark Unread" : "Mark Read", systemImage: book.isRead ? "book.closed" : "book")
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)

                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            let text = "\(book.title) by \(book.author)"
            ActivityView(activityItems: [text])
        }
    }
}

// UIKit share sheet wrapper
private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    @Previewable @State var book = Book(title: "Preview Book", author: "Preview Author", description: "A short description for preview.")
    NavigationStack { BookDetailView(book: $book) }
}
