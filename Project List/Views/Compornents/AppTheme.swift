//  AppTheme.swift
//  Project List
//  アプリ全体の色・角丸・影をまとめる場所
//  UIを差し替えるときは、まずここを書き換える

import SwiftUI

enum AppTheme
{
    // 色
    static let brandTagBackground = Color.blue.opacity(0.1)
    static let brandTagForeground = Color.blue
    static let genreTagBackground = Color.gray.opacity(0.1)
    static let cardBackground = Color(.systemBackground)
    static let subText = Color.gray

    // 角丸
    static let cardCornerRadius: CGFloat = 12
    static let tagCornerRadius: CGFloat = 4
}

extension View
{
    // カードの見た目（背景・角丸・影）
    func cardStyle() -> some View
    {
        self
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cardCornerRadius)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
