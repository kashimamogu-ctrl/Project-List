//　TODO: トンマナ決める時にスペースやパディングなどの数値も定数化する？

import SwiftUI
import SwiftData

struct CalendarTaskDetailModal: View
{
    let day: CalendarDay
    let onClose: () -> Void // モーダルを閉じるための処理
    
    // SwiftData からすべての案件を取得
    @Query private var projects: [Project]
    @State private var isShowingSheet = false
    
    // タップされた日付（day.date）と期限（deadline）が一致する案件だけを抽出
    private var filteredProjects: [Project]
    {
        projects.filter { project in
                project.barPosition(for: day.date) != nil
            }
    }
    
    var body: some View
    {
        ZStack(alignment: .bottomTrailing)
        {
            VStack(spacing: 0)
            {
                // ヘッダー部分
                HStack
                {
                    Text("\(day.date.shortDateText) の予定")
                        .font(.appSection)

                    Spacer()

                    ModalCloseButton(action: onClose)
                }
                .padding(.leading)
                .padding(.vertical, 4)
                .background(AppTheme.surface)
                
                ScrollView
               {
                   VStack(spacing: 12)
                   {
                       // ↓ここから案件一覧
                       ForEach(filteredProjects) { project in
                           NavigationLink (value: project) {
                               HStack
                               {
                                   VStack(alignment: .leading, spacing: 4)
                                   {
                                       Text(project.brand?.name ?? "ブランド未設定")
                                           .font(.caption)
                                           .foregroundColor(AppTheme.subText)
                                       
                                       Text(project.name)
                                           .font(.body)
                                           .fontWeight(.semibold)
                                   }
                                   
                                   Spacer()
                                   
                                   // ステータスバッジなどの表示
                                   StatusBadge(status: project.status)
                               }
                               .padding()
                               .background(AppTheme.background)
                               .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control))
                               .contentShape(Rectangle())
                           }
                           .buttonStyle(.plain)
                       }
                   }
                }
                .padding()
                .frame(maxHeight: 200)
            }
            .modalCardStyle()
            .padding(.horizontal, 24)
            
            // 新規案件作成用＋ボタン
            FloatingAddButton {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isShowingSheet = true
                }
            }
            .padding(.bottom, 8)
            .padding(.trailing, 32)
            .transition(.scale.combined(with: .opacity))
        }
        
        // 新規作成カスタムポップアップ
        if isShowingSheet
        {
            ModalBackdrop { withAnimation { isShowingSheet = false } }
            
            AddProjectView(isPresented: $isShowingSheet, initialDate: day.date)
                .padding(.horizontal, 24)
                .padding(.vertical, 40)
                .transition(.scale(scale: 0.95).combined(with: .opacity))
        }
    }
}
