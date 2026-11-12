import SwiftUI

@main
struct DreamApp: App {
    @State private var store = DreamStore()
    var body: some Scene {
        WindowGroup {
            DreamHome().environment(store).foregroundStyle(Color("Ink")).tint(.white)
                .preferredColorScheme(.dark).environment(\.locale, Locale(identifier: "en_US"))
                .task {
                    #if DEBUG
                    await VisualGrammarProbe.runIfRequested()
                    await InterpretationProbe.runIfRequested()
                    #endif
                }
        }
    }
}
