import SwiftUI

@main
struct PortWatchApp: App {
    var body: some Scene {
        WindowGroup("PortWatch") {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}
