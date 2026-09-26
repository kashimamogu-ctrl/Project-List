//
//  CalendarView.swift
//  Project List
//
//  Created by 菓子間もぐ on 2026/09/20.
//　カレンダー画面

// TODO:色のベタ打ちが横行しているので、ちゃんとファイルにまとめ直してトンマナ定義した時にそこ書き換えるだけでいいようにする

import SwiftUI
import SwiftData

struct CalendarDay: Identifiable, Equatable
{
    let id = UUID()
    let date: Date           // その日の正確な日付データ
    let isCurrentMonth: Bool // 今月の日付かどうか(前月・来月もグレーアウト表示するため)
    let dayNumber: Int       // 表示用の「日」（例: 24）
}

struct CalendarView: View
{
    // 案件一覧の取得
    @Query private var projects: [Project]
    
    // 表示中の年月を管理
    @State private var currentMonth: Date = Date()
    
    // 常に42個（7列 × 6行）のマス目を保持
    @State private var calendarDays: [CalendarDay] = []
    
    // タップされた日付情報を保持
    @State private var selectedDay: CalendarDay?
    
    // 開始曜日の設定（1 = 日曜日, 2 = 月曜日）
    @AppStorage("firstWeekday") private var firstWeekday = 2 // 「１」なら日曜始まり

    private static let daysInWeek = 7 // 1週間の日数
    private static let calendarRowCount = 6 // カレンダーの行数
    private let totalCalendarGridCount = daysInWeek * calendarRowCount
    
    // 曜日の一覧
    private var weekdays: [String]
    {
        let base = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        let shift = firstWeekday - 1
        return Array(base[shift...] + base[..<shift])
    }
    
    // 7列の固定グリッド
    private var columns: [GridItem]
    {
        Array(repeating: GridItem(.flexible(), spacing: 0), count: Self.daysInWeek)
    }
    
    // 特定の日付に該当するプロジェクトとバー位置を取得
    private func projectSegments(for date: Date) -> [CalendarProjectSegment]
    {
        return projects.compactMap { project in
            guard let position = project.barPosition(for: date) else { return nil }
            return CalendarProjectSegment(
                id: project.id.hashValue.description,
                name: project.name,
                status: project.status,
                position: position
            )
        }
    }
    
    var body: some View
    {
        ZStack
        {
            // カレンダーのメイン表示部分
            VStack
            {
                // ヘッダー
                HStack
                {
                    // 上部左のボタン、前の月へ
                    Button(action: { changeMonth(by: -1) })
                    {
                        Image(systemName: "chevron.left")
                            .font(.body).bold().foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 16)
                    {
                        Text(currentMonth, format: .dateTime.year().month().locale(Locale(identifier: "ja_JP")))
                            .font(.title2).bold()
                    }
                    
                    Spacer()
                    
                    // 上部右のボタン、次の月へ
                    Button(action: { changeMonth(by: 1) })
                    {
                        Image(systemName: "chevron.right")
                            .font(.body).bold().foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 8)
                
                // カレンダー本体
                VStack(spacing: 0)
                {
                    // 曜日表示ヘッダー
                    HStack(spacing: 0) {
                        ForEach(weekdays, id: \.self) { weekday in
                            Text(weekday)
                                .font(.caption).bold()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    Divider()
                    
                    // 7列グリッドで CalendarCellView を並べる
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(calendarDays, id: \.id) { item in
                            CalendarCellView(
                                date: item.date,
                                dayNumber: item.dayNumber,
                                isCurrentMonth: item.isCurrentMonth,
                                isToday: Calendar.current.isDateInToday(item.date),
                                segments: projectSegments(for: item.date),
                                onSelect: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedDay = item
                                    }
                                }
                            )
                        }
                    }
                }
                .border(Color.black, width: 0.5)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // 浮き上がるモーダル表示部分
            if let day = selectedDay
            {
                // 暗い背景（タップすると閉じる）
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedDay = nil
                        }
                    }
                
                // ふわっと浮き出るダイアログ
                CalenderTaskDetailModal(day: day) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        selectedDay = nil
                    }
                }
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .navigationTitle("カレンダー")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.2), value: selectedDay)
        .onAppear { updateCalendarDays() }
        .onChange(of: currentMonth) { updateCalendarDays() }
    }
    
    // 特定の日付が締め切りの案件を取得
    private func projects(for date: Date) -> [Project]
    {
        let calendar = Calendar.current
        return projects.filter { project in
            guard let deadline = project.deadline else { return false }
            return calendar.isDate(deadline, inSameDayAs: date)
        }
    }
    
    // 月移動
    private func changeMonth(by value: Int)
    {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth)
        {
            currentMonth = newMonth
        }
    }

    // カレンダー更新
    private func updateCalendarDays()
    {
        calendarDays = generate42Days(for: currentMonth)
    }
    
    // 常に42個（7×6）のマスカレンダーを安全に作る関数
    private func generate42Days(for date: Date) -> [CalendarDay]
    {
        var calendar = Calendar.current
        calendar.firstWeekday = firstWeekday
        
        // 今月の1日を取得
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))
        else
        {//中身がないときは中断
            return []
        }
        
        // 1日が何曜日か（月曜始まりを考慮したオフセット計算）
        let weekdayOfFirst = calendar.component(.weekday, from: startOfMonth)
        let numberOfEmptyDays = (weekdayOfFirst - calendar.firstWeekday + 7) % 7
        
        // カレンダーの「マス目の一番左上（前月の日付）」を割り出す
        guard let startDate = calendar.date(byAdding: .day, value: -numberOfEmptyDays, to: startOfMonth)
        else
        {//中身がないときは中断
            return []
        }
        
        var days: [CalendarDay] = []
        
        // そこから順番に42日分を詰めていく（42個固定）
        for i in 0..<totalCalendarGridCount
        {
            if let currentDate = calendar.date(byAdding: .day, value: i, to: startDate)
            {
                // 今月の日付かどうか判定
                let isCurrentMonth = calendar.isDate(currentDate, equalTo: startOfMonth, toGranularity: .month)
                let dayNum = calendar.component(.day, from: currentDate)
                
                days.append(CalendarDay(
                    date: currentDate,
                    isCurrentMonth: isCurrentMonth,
                    dayNumber: dayNum
                ))
            }
        }
        return days
    }
    
    private func tileBackgroundColor(for item: CalendarDay) -> Color
    {
        if Calendar.current.isDateInToday(item.date)
        {
            return Color.yellow.opacity(0.2)
        }
        else if item.isCurrentMonth
        {
            return Color.white
        }
        else
        {
            return Color.gray.opacity(0.1)
        }
    }
}

// プレビュー用ダミーデータ構造
#Preview
{
    NavigationStack
    {
        CalendarView()
    }
}
