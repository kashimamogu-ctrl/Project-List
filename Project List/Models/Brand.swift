// ブランド画面で主に使うブランドモデルを定義
//　案件リスト画面の案件と結びつきます。
//　一つのブランドにつき多くの案件をもつ、関係としては　ブランド:案件＝１:多　になる。

import Foundation
import SwiftData

// ブランドジャンル
enum BrandGenre: String, CaseIterable, Identifiable, StoredOption
{
    case cosmetics
    case skincare
    case haircare
    case apparel
    case lifestyle
    case other

    var id: String { self.rawValue }

    var label: String
    {
        switch self
        {
        case .cosmetics: return "コスメ"
        case .skincare:  return "スキンケア"
        case .haircare:  return "ヘアケア・ボディケア"
        case .apparel:   return "アパレル"
        case .lifestyle: return "ライフスタイル"
        case .other:     return "その他"
        }
    }
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
        get { BrandGenre.fromStored(genreRawValue) ?? .cosmetics }
        set { genreRawValue = newValue.rawValue }
    }
    
    init(name: String, genre: String, note: String = "")
    {
        self.name = name
        self.genreRawValue = genre
        self.note = note
    }
}


extension Brand
{
    // 名前が一致するブランドを探す（前後の空白は無視）
    static func find(named name: String, in brands: [Brand]) -> Brand?
    {
        let trimmedName = ProjectInputRules.trimmed(name)
        return brands.first { $0.name == trimmedName }
    }
}

extension ModelContext
{
    // 名前が一致するブランドを返す。なければ新しく作る
    func fetchOrCreateBrand(named name: String, genre: BrandGenre) -> Brand
    {
        let trimmedName = ProjectInputRules.trimmed(name)
        let descriptor = FetchDescriptor<Brand>(predicate: #Predicate { $0.name == trimmedName })

        if let existingBrand = try? fetch(descriptor).first
        {
            return existingBrand
        }

        let newBrand = Brand(name: trimmedName, genre: genre.rawValue)
        insert(newBrand)
        return newBrand
    }
}
