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
                .fontDesign(.rounded)               // SF Pro Rounded（日本語はヒラギノ）
                .foregroundStyle(AppTheme.text)     // 文字の基本色
                .tint(AppTheme.main)                // トグルやリンクなどの色
                .preferredColorScheme(.light)       // ダーク用の色が決まるまでライト固定
        }
        .modelContainer(for: [
            Project.self,
            Brand.self,
            UserProfile.self,
            ExternalAccount.self
        ])
    }
}
