//  MonthTaskList.swift
//  Project List
//  カレンダーの下に出す「〇〇月の残りの案件」

import SwiftUI

struct MonthTaskList: View
{
    let month: Date            // カレンダーで表示している月
    let projects: [Project]

    var body: some View
    {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.item)
        {
            Text("\(Calendar.current.component(.month, from: month))月の残りの案件")
                .font(.appTitle)

            if remainingProjects.isEmpty
            {
                Text("この月の残りの案件はありません")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.subText)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .cardStyle()
            }
            else
            {
                ForEach(remainingProjects) { project in
                    NavigationLink(value: project)
                    {
                        ProjectCardContent(project: project)
                            .padding()
                            .cardStyle()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // この月にかかっていて、完了していない案件（期限が近い順）
    private var remainingProjects: [Project]
    {
        projects
            .filter { $0.status != .completed && $0.overlaps(month: month) }
            .sorted { ($0.deadline ?? .distantFuture) < ($1.deadline ?? .distantFuture) }
    }
}
