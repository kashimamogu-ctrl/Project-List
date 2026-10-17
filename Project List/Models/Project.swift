//  Project.swift
//  Project List
//　このアプリのメインとなる案件のモデル

import Foundation
import SwiftData
import SwiftUI

// 案件の進捗状況
// rawValue は保存用のキー。表示名を変えたいときは label だけを変える
enum ProjectStatus: String, CaseIterable, Identifiable, StoredOption
{
    case applied
    case waiting
    case progress
    case completed

    var id: String { self.rawValue }

    var label: String
    {
        switch self
        {
        case .applied:   return "応募済"
        case .waiting:   return "商品受け取り待ち"
        case .progress:  return "進行中"
        case .completed: return "完了"
        }
    }
    
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

// バーの表示位置
enum ProjectBarPosition
{
    case single      // 単日
    case start       // 開始日
    case middle      // 途中
    case end         // 終了日
}

// 案件タイプ
enum ProjectType: String, CaseIterable, Identifiable, StoredOption
{
    case gifting
    case monitor
    case ambassador
    case other

    var id: String { self.rawValue }

    var label: String
    {
        switch self
        {
        case .gifting:    return "ギフティング"
        case .monitor:    return "モニター"
        case .ambassador: return "アンバサダー"
        case .other:      return "その他"
        }
    }
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
        get { ProjectStatus.fromStored(statusRawValue) ?? .applied }
        set { statusRawValue = newValue.rawValue }
    }
    
    var projectType: ProjectType
    {
        get { ProjectType.fromStored(typeRawValue) ?? .gifting }
        set { typeRawValue = newValue.rawValue }
    }
    
    // 期限の表示用テキストを返す計算プロパティ
    var deadlineText: String? {
        guard let deadline = deadline else { return nil }
        
        // 期間指定かつ開始日が存在する場合
        if isRange, let startline = startline,
           !Calendar.current.isDate(startline, inSameDayAs: deadline)
        {
            return "\(startline.shortDateText) 〜 \(deadline.shortDateText)"
        }
        else
        {
            // 単日の場合（例: 〜 2026/09/26）
            return "〜 \(deadline.shortDateText)"
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
