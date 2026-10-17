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
