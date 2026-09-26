//
//  Project.swift
//  Project List
//
//  Created by 菓子間もぐ on 2026/09/20.
//
//　このアプリのメインとなる案件のモデル

import Foundation
import SwiftData
import SwiftUI

// 案件の進捗状況
// TODO：ユーザー自身が追加できるようにしたい
enum ProjectStatus: String, CaseIterable, Identifiable
{
    case applied = "応募済"
    case waiting = "商品受け取り待ち"
    case progress = "進行中"
    case completed = "完了"
    
    var id: String { self.rawValue }
    
    var foregroundColor: Color
    {
        switch self
        {
        case .applied:   return .gray          // 応募済：グレー
        case .waiting:   return .gray        // 待ち：グレー
        case .progress:  return .blue         // 進行中：ブルー
        case .completed: return .green         // 完了：グリーン
        }
    }

    //背景色は各カラーを薄くした色
    var backgroundColor: Color
    {
        self.foregroundColor.opacity(0.12)
    }
}

// 案件タイプ
// TODO：ユーザー自身が追加できるようにしたい
enum ProjectType: String, CaseIterable, Identifiable
{
    case gifting = "ギフティング"
    case monitor = "モニター"
    case ambassador = "アンバサダー"
    case other = "その他"
    
    var id: String { self.rawValue }
}

@Model
final class Project
{
    var name: String                // 案件名（必須）
    
    @Relationship(deleteRule: .nullify)
    var brand: Brand?               // 案件名（必ず案件にはブランドが紐づくため必須）
    
    var productName: String         // 商品名
    var statusRawValue: String       // 進捗（応募済 など）
    var typeRawValue: String  // 案件タイプ
    var hasDuty: Bool               // 投稿義務の有無
    var isRange: Bool              //期限範囲
    var startline: Date?            //始まりの期間
    var deadline: Date?             // 期限
    var note: String                // メモ
    
    //保存のためにStringにしているものはEnumと変換できる機能をもっておく
    var status: ProjectStatus
    {
        get { ProjectStatus(rawValue: statusRawValue) ?? .applied }
        set { statusRawValue = newValue.rawValue }
    }
    
    var projectType: ProjectType
    {
        get { ProjectType(rawValue: typeRawValue) ?? .gifting }
        set { typeRawValue = newValue.rawValue }
    }
    
    // 期限の表示用テキストを返す計算プロパティ
    var deadlineText: String? {
        guard let deadline = deadline else { return nil }
        
        // 期間指定かつ開始日が存在する場合
        if isRange, let startline = startline {
            return "\(startline.localizedYMD) 〜 \(deadline.localizedYMD)"
        } else {
            // 単日の場合（例: 〜 2026/09/26）
            return "〜 \(deadline.localizedYMD)"
        }
    }

    // 特定の日付(date)におけるこの案件のバーの位置判定
    func barPosition(for date: Date) -> ProjectBarPosition? {
        let calendar = Calendar.current
        
        // 1. 範囲指定（isRange）ではない、または開始日がない場合 -> 単日判定
        guard isRange, let start = startline, let end = deadline else {
            if let end = deadline, calendar.isDate(date, inSameDayAs: end) {
                return .single
            }
            return nil
        }
        
        let target = calendar.startOfDay(for: date)
        let startDate = calendar.startOfDay(for: start)
        let endDate = calendar.startOfDay(for: end)

        // 範囲外なら nil
        guard target >= startDate && target <= endDate else { return nil }

        let isStartDay = calendar.isDate(target, inSameDayAs: startDate)
        let isEndDay = calendar.isDate(target, inSameDayAs: endDate)

        if isStartDay && isEndDay {
            return .single
        } else if isStartDay {
            return .start
        } else if isEndDay {
            return .end
        } else {
            return .middle
        }
    }
    
    init(name: String, brand: Brand? = nil, productName: String = "", status: ProjectStatus = .applied, projectType: ProjectType = .gifting, hasDuty: Bool = true, isRange:Bool = false, startline: Date? = nil, deadline: Date? = nil,note: String = "")
    {
           self.name = name
           self.brand = brand
           self.productName = productName
           self.statusRawValue = status.rawValue
           self.typeRawValue = projectType.rawValue
           self.hasDuty = hasDuty
           self.isRange = isRange
           self.startline = startline
           self.deadline = deadline
           self.note = note
    }
}
