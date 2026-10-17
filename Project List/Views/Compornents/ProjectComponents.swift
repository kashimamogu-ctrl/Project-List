//  ProjectComponents.swift
//  Project List
//  案件まわりで何度も使う部品

import SwiftUI

// 進捗バッジ（応募済・進行中など）
struct StatusBadge: View
{
    let status: ProjectStatus

    var body: some View
    {
        Text(status.rawValue)
            .font(.caption)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.backgroundColor)
            .foregroundColor(status.foregroundColor)
            .cornerRadius(AppTheme.tagCornerRadius)
    }
}

// ブランド名のタグ
struct BrandTag: View
{
    let name: String

    var body: some View
    {
        Text(name)
            .font(.caption)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AppTheme.brandTagBackground)
            .foregroundColor(AppTheme.brandTagForeground)
            .cornerRadius(AppTheme.tagCornerRadius)
    }
}

// 案件カードの中身（リストとブランド詳細で共通）
struct ProjectCardContent: View
{
    let project: Project

    var body: some View
    {
        VStack(alignment: .leading, spacing: 4)
        {
            HStack
            {
                BrandTag(name: project.brand?.name ?? "ブランド未設定")
                Spacer()
                StatusBadge(status: project.status)
            }

            Text(project.name)
                .font(.body)
                .bold()
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !project.productName.isEmpty
            {
                Text("商品: \(project.productName)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let deadlineText = project.deadlineText
            {
                HStack
                {
                    Spacer()
                    Text(deadlineText)
                        .font(.caption2)
                        .foregroundColor(AppTheme.subText)
                }
                .padding(.top, 4)
            }
        }
    }
}

// 期限の入力欄（作成画面と編集画面で共通）
struct DeadlineFields: View
{
    @Binding var hasDeadline: Bool
    @Binding var isRange: Bool
    @Binding var startline: Date
    @Binding var deadline: Date

    var body: some View
    {
        FormField(title: "期限")
        {
            Toggle("期限を設定する", isOn: $hasDeadline)
        }

        if hasDeadline
        {
            VStack(alignment: .leading, spacing: 8)
            {
                Toggle("期間で指定する", isOn: Binding(
                    get: { isRange },
                    set: { newValue in
                        isRange = newValue
                        // 期間指定をONにしたら、開始日を締切日に揃える
                        if newValue { startline = deadline }
                    }
                ))
                .toggleStyle(CheckboxToggleStyle())

                if isRange
                {
                    DatePicker("開始日", selection: $startline, displayedComponents: .date)
                        .onChange(of: startline) { _, newValue in
                            // 開始日が終了日より後になったら、終了日を揃える
                            if newValue > deadline { deadline = newValue }
                        }

                    DatePicker("終了日", selection: $deadline, displayedComponents: .date)
                        .onChange(of: deadline) { _, newValue in
                            // 終了日が開始日より前になったら、開始日を揃える
                            if newValue < startline { startline = newValue }
                        }
                }
                else
                {
                    DatePicker("期日", selection: $deadline, displayedComponents: .date)
                }
            }
            .environment(\.locale, Locale(identifier: "ja_JP"))
        }
    }
}
