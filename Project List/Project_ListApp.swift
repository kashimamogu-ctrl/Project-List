// アプリの起動が始まるファイル

import SwiftUI
import SwiftData

@main
struct Project_ListApp: App
{
    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
        }
        .modelContainer(for: [Project.self, Brand.self])
    }
}
