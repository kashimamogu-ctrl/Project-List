//　メイン画面

import SwiftUI
import SwiftData

struct ContentView: View
{    
    // 現在どのタブが選ばれているか
    @State private var selectedTab = 1
    // タブを切り替えた回数（カレンダーのモーダルを閉じる判定に使う）
    @State private var tabChangeCount = 0
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            TabView(selection: $selectedTab)
            {
                NavigationStack
                {
                    CalendarView(tabChangeCount: tabChangeCount)
                }
                .tabItem {
                    Label("カレンダー", systemImage: "calendar")
                }
                .tag(0) // タブの識別番号
                
                NavigationStack
                {
                    ProjectListView()
                }
                .tabItem {
                    Label("リスト", systemImage: "list.bullet")
                }
                .tag(1)
                
                NavigationStack
                {
                    BrandListView()
                }
                .tabItem {
                    Image(systemName: "tag.fill")
                    Text("ブランド")
                }
                .tag(2)
                
                NavigationStack
                {
                    MyPageView()
                }
                .tabItem {
                    Label("マイページ", systemImage: "person.fill")
                }
                .tag(3)
            }
            .onChange(of: selectedTab)
            {
                tabChangeCount += 1 // カレンダーで開いていた詳細画面を閉じる
            }
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithDefaultBackground()
                
                appearance.backgroundColor = UIColor.systemGray6
                UITabBar.appearance().scrollEdgeAppearance = appearance
                UITabBar.appearance().standardAppearance = appearance
            }
            .accentColor(.blue)
            AdBannerView()
        }
    }
}
