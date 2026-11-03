// アプリの起動が始まるファイル

import SwiftUI
import SwiftData

@main
struct Project_ListApp: App
{
    init()
    {
        // 画面上のタイトルを、丸いフォント・本文の色にする
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.titleTextAttributes = [
            .font: UIFont.rounded(size: 17, weight: .semibold),
            .foregroundColor: UIColor(AppTheme.text)
        ]
        navAppearance.largeTitleTextAttributes = [
            .font: UIFont.rounded(size: 28, weight: .bold),
            .foregroundColor: UIColor(AppTheme.text)
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        // タブバーの背景を、アプリの背景色にする
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(AppTheme.background)
        tabAppearance.shadowColor = UIColor(AppTheme.line)   // タブバーの上の細い線

        // 選んでいないタブのアイコンと文字の色
        let normal = tabAppearance.stackedLayoutAppearance.normal
        normal.iconColor = UIColor(AppTheme.subText)
        normal.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.subText)]

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }

    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
                .fontDesign(.rounded)               // SF Pro Rounded（日本語はヒラギノ）
                .foregroundStyle(AppTheme.text)     // 文字の基本色
                .tint(AppTheme.main)                // 選んでいるタブ・トグルなどの色
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
