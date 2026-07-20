import Observation

// This model is currently optional because ContentView uses Library.
// It remains valid if you want to use it later.
@Observable
final class Catalog {
    var listings: [Book]
    var myLibrary: [Book]

    init(listings: [Book] = [], myLibrary: [Book] = []) {
        self.listings = listings
        self.myLibrary = myLibrary
    }
}
