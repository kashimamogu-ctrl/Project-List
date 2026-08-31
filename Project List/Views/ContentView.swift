//
//  CalendarView.swift
//  Project List
//
//  Created by 菓子間もぐ on 2026/09/20.
//　メイン画面

import SwiftUI
import SwiftData

struct ContentView: View
{
    @Environment(\.modelContext) private var modelContext
    
    // 現在どのタブが選ばれているか
    @State private var selectedTab = 1
    
    var body: some View
    {
        TabView(selection: $selectedTab)
        {
            
            CalendarView()
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
            
            BrandView()
                .tabItem {
                    Label("ブランド", systemImage: "tag")
                }
                .tag(2)
            
            MyPageView()
                .tabItem {
                    Label("マイページ", systemImage: "person.fill")
                }
                .tag(3)
        }

        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
  
            appearance.backgroundColor = UIColor.systemGray6
            UITabBar.appearance().scrollEdgeAppearance = appearance
            UITabBar.appearance().standardAppearance = appearance
        }
        .accentColor(.blue) 
    }
}
