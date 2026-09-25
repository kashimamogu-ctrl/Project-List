//
//  TaskDetailSheetView.swift
//  Project List
//
//  Created by 菓子間もぐ on 2026/09/25.
//
//　TODO: トンマナ決める時にスペースやパディングなどの数値も定数化する？

import SwiftUI
import SwiftData

struct CalenderTaskDetailModal: View
{
    let day: CalendarDay
    let onClose: () -> Void // モーダルを閉じるための処理
    
    // SwiftData からすべての案件を取得
    @Query private var projects: [Project]
    
    // タップされた日付（day.date）と期限（deadline）が一致する案件だけを抽出
    private var filteredProjects: [Project]
    {
        let calendar = Calendar.current
        return projects.filter
        { project in
            guard let deadline = project.deadline
            else { return false }//なければ中断
            return calendar.isDate(deadline, inSameDayAs: day.date)
        }
    }
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            // ヘッダー部分
            HStack
            {
                //TODO：数値に変更して表示は英語と日本語表記の2パターンにする
                Text("\(day.date.formatted(.dateTime.month().day())) の予定")
                    .font(.headline)
                    .bold()
                
                Spacer()
                
                // 閉じるボタン
                Button(action: onClose)
                {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
            .padding()
            .background(Color(.systemGray6))
            
            VStack(alignment: .leading, spacing: 16)
            {
                ScrollView
                {
                    VStack(spacing: 12)
                    {
                        ForEach(filteredProjects) { project in
                            HStack
                            {
                                VStack(alignment: .leading, spacing: 4)
                                {
                                    Text(project.brand?.name ?? "ブランド未設定")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Text(project.name)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                }
                                
                                Spacer()
                                
                                // ステータスバッジなどの表示
                                Text(project.status.rawValue)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                }
            }
            .padding()
            .frame(maxHeight: 200)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 24)
    }
}
