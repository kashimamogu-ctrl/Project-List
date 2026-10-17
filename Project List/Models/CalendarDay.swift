//  CalendarDay.swift
//  Project List

import Foundation

struct CalendarDay: Identifiable, Equatable
{
    let id = UUID()
    let date: Date           // その日の正確な日付データ
    let isCurrentMonth: Bool // 今月の日付かどうか(前月・来月もグレーアウト表示するため)
    let dayNumber: Int       // 表示用の「日」（例: 24）
}
