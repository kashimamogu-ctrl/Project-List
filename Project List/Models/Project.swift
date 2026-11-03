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
    
    // 進捗の流れが色でわかるようにする
    var foregroundColor: Color
    {
        switch self
        {
        case .applied:   return AppTheme.subText     // 応募済：まだ始まっていない
        case .waiting:   return AppTheme.main        // 待ち：もうすぐ動き出す
        case .progress:  return AppTheme.progress    // 進行中：今やっている
        case .completed: return AppTheme.completed   // 完了：終わった
        }
    }

    // バッジの文字色（小さい文字でも読みやすいように濃いめ）
    var textColor: Color
    {
        switch self
        {
        case .applied:   return AppTheme.appliedText
        case .waiting:   return AppTheme.accent
        case .progress:  return AppTheme.progressText
        case .completed: return AppTheme.completedText
        }
    }

    // バッジの背景色は各色を薄くした色
    var backgroundColor: Color
    {
        self.foregroundColor.opacity(0.15)
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
    
    // 指定した月に、この案件の期間がかかっているか（期限なしは対象外）
    func overlaps(month: Date) -> Bool
    {
        guard let deadline else { return false }

        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else { return false }

        // 期間の案件は開始日から、単日の案件は期限の日だけ
        let start = calendar.startOfDay(for: (isRange ? startline : nil) ?? deadline)

        // 案件の期間と、その月の期間が重なっているか
        return start < monthInterval.end && deadline >= monthInterval.start
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
