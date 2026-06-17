import SwiftUI
import SwiftData

@main
struct food_journalApp: App {
    init() {
        UIFont.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: JournalEntry.self)
    }
}
