//TODO: 絞り込み機能は最初「全て」「未完了のみ」「期限超過」の３つにする

import SwiftUI
import SwiftData

struct ProjectListView: View
{
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Project.deadline)]) private var projects: [Project] // 期限が近い順に並べる
    
    @State private var isShowingSheet = false
    @State private var viewModel = ProjectListViewModel()
    
    // 画面のデザインを崩さないための独自管理変数
    @State private var isEditMode: Bool = false
    @State private var selectedProjectIDs = Set<Project.ID>()
    @State private var isShowingDeleteAlert = false
    @State private var selectedFilterStatus: ProjectStatus? = nil
    
    var body: some View
    {
        ZStack(alignment: .bottomTrailing)
        {
            ScrollView
            {
                ScrollView(.horizontal, showsIndicators: false)
                {
                    HStack(spacing: 8)
                    {
                        FilterChip(title: "すべて", isSelected: selectedFilterStatus == nil) {
                            selectedFilterStatus = nil
                        }

                        ForEach(ProjectStatus.allCases) { status in
                            FilterChip(title: status.label, isSelected: selectedFilterStatus == status) {
                                selectedFilterStatus = status
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.screen)
                    .padding(.vertical, 10)
                }
                
                
                VStack(spacing: 16)
                {
                    if filteredProjects.isEmpty
                    {
                        if projects.isEmpty
                        {
                            // 案件がまだ1件もないとき
                            EmptyStateView(
                                title: "まだ案件がありません",
                                message: "右下の＋ボタンから、最初の案件を追加してみましょう"
                            )
                        }
                        else
                        {
                            // 絞り込んだら0件になったとき
                            EmptyStateView(title: "「\(selectedFilterStatus?.label ?? "")」の案件はありません")
                        }
                    }
                    
                    ForEach(filteredProjects){ project in
                        ZStack
                        {
                            // 1. 【最奥】通常モード時のみ、裏側に透明なボタンとしてNavigationLinkを配置
                            if !isEditMode
                            {
                                NavigationLink(value: project)
                                {
                                    Color.clear // 完全に透明な下地。これで文字が薄くなるのを100%防ぎます
                                }
                            }
                            
                            // 2. 【手前】見た目を担当するクッキリしたカード本体
                            HStack(spacing: 12)
                            {
                                // 編集モード時のチェックボックス
                                if isEditMode
                                {
                                    Button(action: {
                                        if selectedProjectIDs.contains(project.id)
                                        {
                                            selectedProjectIDs.remove(project.id)
                                        } else
                                        {
                                            selectedProjectIDs.insert(project.id)
                                        }
                                    })
                                    {
                                        Image(systemName: selectedProjectIDs.contains(project.id) ? "checkmark.circle.fill" : "circle")
                                            .font(.title2)
                                            .foregroundColor(selectedProjectIDs.contains(project.id) ? .red : AppTheme.subText)
                                            .frame(width: 44, height: 44)
                                    }
                                    .buttonStyle(.borderless)
                                    .transition(.move(edge: .leading).combined(with: .opacity))
                                }
                                ProjectCardContent(project: project)
                            }
                            .padding()
                        }
                        .cardStyle()
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.screen)
                .padding(.top, 16)
            }
            
            // 左下の選択削除と右下の＋、ゴミ箱ボタン
            VStack
            {
                Spacer()
                HStack
                {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditMode.toggle()
                            if !isEditMode { selectedProjectIDs.removeAll() }
                        }
                    }) {
                        Text(isEditMode ? "完了" : "選択削除")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(isEditMode ? AppTheme.accent : AppTheme.subText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(AppTheme.card)
                            .clipShape(Capsule())
                            .appShadow()
                    }
                    .padding(.leading, 24)
                    .padding(.bottom, 16)
                    
                    Spacer()
                    
                    if isEditMode
                    {
                        Button(action: {
                            isShowingDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 52, height: 52)
                                .background(Color.red.opacity(selectedProjectIDs.isEmpty ? 0.4 : 1))
                                .clipShape(Circle())
                                .appShadow()
                        }
                        .disabled(selectedProjectIDs.isEmpty)
                        .padding(.trailing, 24)
                        .padding(.bottom, 16)
                        .transition(.scale.combined(with: .opacity))
                    }
                    else
                    {
                        FloatingAddButton {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isShowingSheet = true
                            }
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 16)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            
            // 新規作成カスタムポップアップ
            if isShowingSheet
            {
                ModalBackdrop {
                    withAnimation { isShowingSheet = false }
                }
                
                AddProjectView(isPresented: $isShowingSheet)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 40)
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
            }
        }
        .background(AppTheme.background)
        .navigationTitle("案件一覧")
        // タブを切り替えたら新規作成ポップアップを閉じる
        .navigationDestination(for: Project.self) { project in
            ProjectDetailView(project: project)
        }
        .onDisappear {
            isShowingSheet = false
        }
        // 一括削除のアラートポップアップ
        .deleteAlert(
            "案件の削除",
            isPresented: $isShowingDeleteAlert,
            message: "選択された \(selectedProjectIDs.count) 件の案件を完全に削除しますか？"
        ) {
            withAnimation
            {
                viewModel.deleteMultipleProjects(ids: selectedProjectIDs, from: projects, in: modelContext)
                isEditMode = false
            }
        }
    }
    
    // 期限なしの案件は一番下に並べる
    private var sortedProjects: [Project]
    {
        projects.filter { $0.deadline != nil } + projects.filter { $0.deadline == nil }
    }
    
    private var filteredProjects: [Project]
    {
        if let filterStatus = selectedFilterStatus
        {
            return sortedProjects.filter { $0.status == filterStatus }
        }
        else
        {
            return sortedProjects
        }
    }
}

#Preview
{
    // 1. メモリ上だけに保存される（アプリ本体のデータを汚さない）プレビュー用コンテナを作成
    let schema = Schema([Project.self, Brand.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    // 2. プレビュー用のコンテキスト（データ操作窓口）を取得
    let context = container.mainContext

    // 3. テスト用のブランド（Brand）を生成
    let brandApple = Brand(name: "Apple Love", genre: BrandGenre.cosmetics.rawValue, note: "")
    let brandNike = Brand(name: "Nike Sports", genre: BrandGenre.apparel.rawValue, note: "")

    // 4. テスト用の案件（Project）を生成（ブランドを紐付ける）
    let project1 = Project(
        name: "新作リップ X（旧Twitter）投稿案件",
        brand: brandApple,
        productName: "ぽってりリップ 01 ダークチェリー",
        status: .applied, // 応募済
        projectType: .gifting,
        hasDuty: true,
        isRange: false,
        startline: Date(),
        deadline: Date(),
        note: ""
    )

    let project2 = Project(
        name: "秋の新作スニーカー Instagramリール投稿",
        brand: brandNike,
        productName: "Air Max 2026",
        status: .applied, // 選考中など（お手持ちのEnumに合わせてください）
        projectType: .gifting,
        hasDuty: false,
        isRange: false,
        startline: Date(),
        deadline: Date().addingTimeInterval(86400 * 3), // 3日後
        note: ""
    )

    // 5. 生成したダミーデータをコンテキストに挿入
    context.insert(project1)
    context.insert(project2)

    // 6. ダミーデータが注入されたコンテナをViewに渡して表示
    return NavigationStack {
        ProjectListView()
    }
    .modelContainer(container)
}
