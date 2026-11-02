//  AppTheme.swift
//  Project List
//  アプリ全体の色・角丸・影をまとめる場所
//  UIを差し替えるときは、まずここを書き換える
import SwiftUI

enum AppTheme
{
    // MARK: 色
    static let background = Color(hex: 0xFBF7F5)   // 背景
    static let card       = Color.white            // カード
    static let surface    = Color(hex: 0xF1E3E8)   // 面色（タグ・選択前のチップなど）
    static let main       = Color(hex: 0xD887A0)   // メイン
    static let accent     = Color(hex: 0xA3506A)   // アクセント（ピンク系）
    // 進捗の色（背景・バー用と、バッジの文字用の濃い色）
    static let progress       = Color(hex: 0x5095A3)   // 進行中
    static let progressText   = Color(hex: 0x3A7480)
    static let completed      = Color(hex: 0xD0A040)   // 完了
    static let completedText  = Color(hex: 0x4F7A3D)
    static let appliedText    = Color(hex: 0x6E6368)   // 応募済の文字
    static let text       = Color(hex: 0x433A3D)   // 本文
    static let subText    = Color(hex: 0x897D82)   // 補助文字
    static let line       = Color(hex: 0xEEE5E6)   // 線（区切り・入力欄の枠）
    static let shadow     = Color(hex: 0x8C7480).opacity(0.12) // 影

    // MARK: 余白
    enum Spacing
    {
        static let screen: CGFloat = 20    // 画面左右の余白
        static let section: CGFloat = 24   // セクション間
        static let item: CGFloat = 12      // 項目間
    }

    // MARK: 大きさ
    enum Size
    {
        static let control: CGFloat = 48    // ボタン・入力欄の高さ
        static let smallIcon: CGFloat = 18  // 小さなラベル・補助アイコン（16〜20pt）
        static let tapTarget: CGFloat = 44  // タップできる範囲の最小サイズ
    }

    // MARK: 角丸
    enum Radius
    {
        static let large: CGFloat = 16     // 大きなカード・ポップアップ
        static let control: CGFloat = 12   // ボタン・入力欄
        static let small: CGFloat = 8      // 小さなラベル・ステータス表示
    }

    // MARK: 線
    static let lineWidth: CGFloat = 1

    // MARK: 今までの名前（呼び出し側を一気に変えなくていいように残しておく）
    static var cardBackground: Color { card }
    static var brandTagBackground: Color { surface }
    static var brandTagForeground: Color { accent }
    static var genreTagBackground: Color { surface }
    static var cardCornerRadius: CGFloat { Radius.large }
    static var tagCornerRadius: CGFloat { Radius.small }
}

// MARK: 文字の太さのルール
extension Font
{
    static let appTitle   = Font.title2.weight(.bold)        // 画面タイトル
    static let appSection = Font.headline.weight(.semibold)  // セクション見出し
    static let appButton  = Font.body.weight(.medium)        // ボタン・選択中の項目
    static let appBody    = Font.body                        // 本文
    static let appCaption = Font.caption                     // 補助情報
}

extension Color
{
    // 0xD887A0 のような16進数のカラーコードから色を作る
    init(hex: UInt32)
    {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

extension View
{
    // 少し浮いて見える影（カード・ボタン用。入力欄や区切り線には付けない）
    func appShadow() -> some View
    {
        // デザインツールの「ぼかし8pt」は、SwiftUI の radius だと半分の 4 くらい
        shadow(color: AppTheme.shadow, radius: 4, x: 0, y: 2)
    }

    // カードの見た目（白・角丸16・影）
    func cardStyle() -> some View
    {
        self
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large))
            .appShadow()
    }
}
