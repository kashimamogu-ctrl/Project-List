//
//  Brand.swift
//  Project List
//
//  Created by 菓子間もぐ on 2026/09/20.
//
// ブランド画面で主に使うブランドモデルを定義
//　案件リスト画面の案件と結びつきます。
//　一つのブランドにつき多くの案件をもつ、関係としては　ブランド:案件＝１:多　になる。

import Foundation
import SwiftData

// ブランドジャンル
enum BrandGenre: String, CaseIterable, Identifiable
{
    case cosmetics = "コスメ"
    case skincare = "スキンケア"
    case haircare = "ヘアケア・ボディケア"
    case apparel = "アパレル"
    case lifestyle = "ライフスタイル"
    case other = "その他"
    
    var id: String { self.rawValue }
}

@Model
final class Brand
{
    var name: String // ブランド名
    var genreRawValue: String // ブランドジャンル
    var note: String //メモ
    
    // １つのブランドに紐づく案件を自動取得する設定
    // ブランドが削除されたら、紐づく案件も一緒に削除する
    @Relationship(deleteRule: .cascade, inverse: \Project.brand)
    var projects: [Project] = []
    
    //enumに変換
    var genre: BrandGenre
    {
        get { BrandGenre(rawValue: genreRawValue) ?? .cosmetics }
        set { genreRawValue = newValue.rawValue }
    }
    
    init(name: String, genre: String, note: String = "")
    {
        self.name = name
        self.genreRawValue = genre
        self.note = note
    }
}
