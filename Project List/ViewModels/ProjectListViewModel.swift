//  案件リスト画面で使うモデルを監視

import Foundation
import Observation
import SwiftData

@Observable
class ProjectListViewModel
{
    //　案件の複数削除
    func deleteMultipleProjects(ids: Set<Project.ID>, from projects: [Project], in modelContext: ModelContext)
    {
        // 選択されたIDに一致する案件だけを抽出して削除
        for project in projects
        {
            if ids.contains(project.id)
            {
                modelContext.delete(project)
            }
        }
    }
}
