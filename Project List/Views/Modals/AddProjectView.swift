//  案件リスト画面の案件の新規追加用モーダルのポップアップ


import SwiftUI
import SwiftData
import os

private let logger = Logger(subsystem: "com.example.app", category: "AddProject")

struct AddProjectView: View
{
    @Environment(\.modelContext) private var modelContext
    
    @Binding var isPresented: Bool//他の場所からもモーダルが開く状態をいじれるようにしておく
    
    // フォームの入力状態を管理するState
    @State private var name: String = ""
    @State private var brandName: String = ""
    @State private var productName: String = ""
    @State private var selectedGenre: BrandGenre? = nil
    @State private var selectedStatus: ProjectStatus = .applied   // 初期値：応募済
    @State private var selectedType: ProjectType = .gifting       // 初期値：ギフティング
    @State private var hasDuty: Bool = false
    @State private var hasDeadline = true
    @State private var isRange = false
    @State private var startline: Date = Date()
    @State private var deadline: Date = Date()
    @State private var note: String = ""
    @Query private var brands: [Brand]
    
    // 入力中のブランド名に一致する既存ブランド
    private var existingBrand: Brand?
    {
        Brand.find(named: brandName, in: brands)
    }
    
    // 期日の初期値を外から渡せるようにする（渡さなければ今日）
    init(isPresented: Binding<Bool>, initialDate: Date = Date())
    {
        self._isPresented = isPresented
        self._startline = State(initialValue: initialDate)
        self._deadline = State(initialValue: initialDate)
    }
    
    // バリデーション：必須項目がすべて埋まっているかと、文字数制限内に収まっているか
    private var isValid: Bool
    {
        ProjectInputRules.isValidRequired(name, maxLength: ProjectInputRules.nameMaxLength)
        && ProjectInputRules.isValidRequired(brandName, maxLength: ProjectInputRules.brandNameMaxLength)
        && ProjectInputRules.isWithinLimit(productName, maxLength: ProjectInputRules.productNameMaxLength)
        && (existingBrand != nil || selectedGenre != nil)
    }
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            ZStack
            {//画面上部の表示
                Text("新規案件作成")
                    .font(.headline)
                    .bold()
                
                HStack
                {
                    Button("キャンセル")
                    {
                        isPresented = false
                    }
                    .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button("作成")
                    {
                        saveProject()
                    }
                    .font(.headline)
                    .bold()
                    .foregroundColor(isValid ? .blue : .gray)
                    .disabled(!isValid)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            
            // 入力フォーム
            ScrollView
            {
                VStack(alignment: .leading, spacing: 16)
                {
                    // 案件名(必須)
                    FormField(title: "案件名", isRequired: true)
                    {
                        TextField("例) Apple Love様新作リップ X投稿", text: $name)
                            .textFieldStyle(.roundedBorder)
                        CharacterCountText(text: name, maxLength: ProjectInputRules.nameMaxLength)
                    }
                    
                    // ブランド名（必須）
                    FormField(title: "ブランド名", isRequired: true)
                    {
                        TextField("例) Apple Love", text: $brandName)
                            .textFieldStyle(.roundedBorder)
                        CharacterCountText(text: brandName, maxLength: ProjectInputRules.brandNameMaxLength)
                    }
                    
                    // 商品名
                    FormField(title: "商品名", isRequired: false)
                    {
                        TextField("例) ぽってりリップ 01 ダークチェリー", text: $productName)
                            .textFieldStyle(.roundedBorder)
                        CharacterCountText(text: productName, maxLength: ProjectInputRules.productNameMaxLength)
                    }
                    
                    // ブランドジャンル（選択）
                    FormField(title: "ブランドジャンル", isRequired: true)
                    {
                        if let existingBrand
                        {
                            // 既存ブランドのジャンルは表示のみ（変更はブランド編集画面で）
                            DropdownLabel(text: selectedGenre?.label ?? "選択してください", isPlaceholder: selectedGenre == nil)
                                .opacity(0.6)
                            Text("登録済みのブランドです。ジャンルはブランド画面で変更できます。")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        else
                        {
                            Menu
                            {
                                ForEach(BrandGenre.allCases)
                                { genre in
                                    Button(genre.label)
                                    {
                                        selectedGenre = genre
                                    }
                                }
                            }label:{
                                DropdownLabel(text: selectedGenre?.label ?? "選択してください", isPlaceholder: selectedGenre == nil)
                            }
                        }
                    }
                    
                    // 進捗（選択）
                    FormField(title: "進捗", isRequired: false)
                    {
                        Menu
                        {
                            ForEach(ProjectStatus.allCases) { status in
                                Button(status.label)
                                {
                                    selectedStatus = status
                                }
                            }
                        } label: {
                            DropdownLabel(text: selectedStatus.label)
                        }
                    }
                    
                    // 案件タイプ（選択）
                    FormField(title: "案件タイプ", isRequired: false)
                    {
                        Menu
                        {
                            ForEach(ProjectType.allCases) { type in
                                Button(type.label) {
                                    selectedType = type
                                }
                            }
                        } label: {
                            DropdownLabel(text: selectedType.label)
                        }
                    }
                    
                    // 投稿義務（ラジオボタン）
                    FormField(title: "投稿義務", isRequired: false)
                    {
                        HStack(spacing: 24)
                        {
                            RadioButton(title: "あり", isSelected: hasDuty)
                            {
                                hasDuty = true
                            }
                            RadioButton(title: "なし", isSelected: !hasDuty)
                            {
                                hasDuty = false
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // 期限
                    DeadlineFields(
                        hasDeadline: $hasDeadline,
                        isRange: $isRange,
                        startline: $startline,
                        deadline: $deadline
                    )
                    
                    FormField(title: "メモ", isRequired: false)
                    {
                        TextEditor(text: $note)
                            .frame(minHeight: 80)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(.systemGray4), lineWidth: 0.5))
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
    
    // 保存ロジック
    private func saveProject()
    {
        let fetchedBrand = modelContext.fetchOrCreateBrand(named: brandName, genre: selectedGenre ?? .other)
        
        let newProject = Project(
            name: ProjectInputRules.trimmed(name),
            brand: fetchedBrand,
            productName: ProjectInputRules.trimmed(productName),
            status: selectedStatus,
            projectType: selectedType,
            hasDuty: hasDuty,
            isRange: hasDeadline && isRange,
            startline: hasDeadline ? startline : nil,
            deadline: hasDeadline ? deadline : nil,
            note: note
        )
        
        modelContext.insert(newProject)
        isPresented = false
        
        logger.info("作成ボタンが押されました！")//LOG:データ変更による作成ができなくなることがないかチェックするため
    }
}
