import Foundation

@Observable
final class Catalog {
    fileprivate var listings: [Book]
    fileprivate var myLibrary: [Book]

    fileprivate init(listings: [Book] = [], myLibrary: [Book] = []) {
        self.listings = listings
        self.myLibrary = myLibrary
    }
}
