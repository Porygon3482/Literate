Literate update

Replace these existing files in Xcode:
- ContentView.swift
- HomeView.swift
- BookDetailView.swift
- LibraryMapView.swift
- Catalog.swift

Add this new file to the Literate target:
- AddBookView.swift

Important:
1. When adding AddBookView.swift, make sure "Literate" is checked under Add to targets.
2. Do not add project.pbxproj, xcuserdata, or workspace metadata as source files.
3. Run on an iPhone Simulator to avoid physical-device provisioning errors.

What changed:
- My Library now has a + button in the top-right corner.
- The + button opens a form for title, author, description/notes, favorite, and read status.
- Added books appear immediately in My Library.
- My Library is saved locally with UserDefaults, so books remain after restarting the app.
- The public map uses a separate listings array.
- Personal library books are never added to the map.
- BookDetailView's malformed Group block was corrected.
