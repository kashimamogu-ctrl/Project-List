import SwiftUI
import SwiftData
import Foundation

struct ProjectDetailView: View
{
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 表示・編集対象の案件モデル
    var project: Project
    
    @State private var isEditMode = false
    @State private var name: String = ""
    @State private var brandName: String = ""
    @State private var productName: String = ""
    @State private var selectedGenre: BrandGenre = .other
    @State private var selectedStatus: ProjectStatus = .applied
    @State private var selectedType: ProjectType = .gifting
    @State private var hasDuty: Bool = false
    @State private var deadline: Date = Date()
    @State private var hasDeadline: Bool = true
    @State private var isRange: Bool = false
    @State private var startline: Date = Date()
    @State private var note: String = ""
    @State private var isShowingDeleteAlert = false // 削除用のアラート管理
    
    @Query private var brands: [Brand]

    // 入力中のブランド名に一致する既存ブランド
    private var existingBrand: Brand?
    {
        let trimmedName = ProjectInputRules.trimmed(brandName)
        return brands.first { $0.name == trimmedName }
    }
    
    // バリデーション：必須項目が埋まっているか
    private var isValid: Bool
    {
        ProjectInputRules.isValidRequired(name, maxLength: ProjectInputRules.nameMaxLength)
        && ProjectInputRules.isValidRequired(brandName, maxLength: ProjectInputRules.brandNameMaxLength)
        && ProjectInputRules.isWithinLimit(productName, maxLength: ProjectInputRules.productNameMaxLength)
    }
    
    var body: some View
    {
        Form
        {
            if isEditMode
            {
                Section(header: Text("基本情報の編集")) {
                    FormField(title: "案件名", isRequired: true) {
                        TextField("案件名を入力", text: $name)
                            .textFieldStyle(.roundedBorder)
                        CharacterCountText(text: name, maxLength: ProjectInputRules.nameMaxLength)
                    }
                    
                    FormField(title: "ブランド名", isRequired: true) {
                        TextField("ブランド名を入力", text: $brandName)
                            .textFieldStyle(.roundedBorder)
                        CharacterCountText(text: brandName, maxLength: ProjectInputRules.brandNameMaxLength)
                    }
                    
                    FormField(title: "商品名", isRequired: false) {
                        TextField("商品名を入力", text: $productName)
                            .textFieldStyle(.roundedBorder)
                        CharacterCountText(text: productName, maxLength: ProjectInputRules.productNameMaxLength)
                    }
                    
                    FormField(title: "ブランドジャンル", isRequired: true) {
                        if let existingBrand
                        {
                            // 既存ブランドのジャンルは表示のみ（変更はブランド編集画面で）
                            DropdownLabel(text: existingBrand.genre.rawValue)
                                .opacity(0.6)
                            Text("登録済みのブランドです。ジャンルはブランド画面で変更できます。")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        else
                        {
                            Menu {
                                ForEach(BrandGenre.allCases) { genre in
                                    Button(genre.rawValue) { selectedGenre = genre }
                                }
                            } label: {
                                DropdownLabel(text: selectedGenre.rawValue)
                            }
                        }
                    }
                }
                
                Section(header: Text("ステータスと条件の編集"))
                {
                    FormField(title: "進捗", isRequired: false)
                    {
                        Menu {
                            ForEach(ProjectStatus.allCases) { status in
                                Button(status.rawValue) { selectedStatus = status }
                            }
                        } label: {
                            DropdownLabel(text: selectedStatus.rawValue)
                        }
                    }
                    
                    FormField(title: "案件タイプ", isRequired: false) {
                        Menu {
                            ForEach(ProjectType.allCases) { type in
                                Button(type.rawValue) { selectedType = type }
                            }
                        } label: {
                            DropdownLabel(text: selectedType.rawValue)
                        }
                    }
                    
                    FormField(title: "投稿義務", isRequired: false) {
                        HStack(spacing: 24) {
                            RadioButton(title: "あり", isSelected: hasDuty) { hasDuty = true }
                            RadioButton(title: "なし", isSelected: !hasDuty) { hasDuty = false }
                        }
                    }
                    
                    DeadlineFields(
                        hasDeadline: $hasDeadline,
                        isRange: $isRange,
                        startline: $startline,
                        deadline: $deadline
                    )
                }
                
                Section(header: Text("メモの編集")) {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }
                
            }
            //編集モードではないとき
            else
            {
                Section(header: Text("基本情報")) {
                    LabeledContent("ブランド名") { Text(project.brand?.name ?? "未設定").bold() }
                    LabeledContent("ジャンル") { Text(project.brand?.genre.label ?? "その他") }
                    LabeledContent("案件名") { Text(project.name) }
                    if !project.productName.isEmpty {
                        LabeledContent("商品名") { Text(project.productName) }
                    }
                }
                
                Section(header: Text("ステータスと条件"))
                {
                    HStack {
                        Text("進捗")
                        Spacer()
                        StatusBadge(status: project.status)
                    }
                    LabeledContent("案件タイプ") { Text(project.projectType.label) }
                    HStack {
                        Text("投稿義務")
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: project.hasDuty ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(project.hasDuty ? .blue : .gray)
                            Text(project.hasDuty ? "あり" : "なし")
                        }
                    }
                    LabeledContent("期限")
                    {
                        Text(project.deadlineText ?? "なし")
                    }
                }
                
                Section(header: Text("メモ")) {
                    if project.note.isEmpty {
                        Text("メモはありません").foregroundColor(.gray).italic()
                    } else {
                        Text(project.note).frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Section {
                    Button(role: .destructive) { isShowingDeleteAlert = true } label: {
                        HStack { Spacer(); Image(systemName: "trash"); Text("この案件を削除する"); Spacer() }
                    }
                }
            }
        }
        .navigationTitle(isEditMode ? "案件の編集" : "案件詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditMode {
                    Button("保存") {
                        updateProject()
                    }
                    .bold()
                    .disabled(!isValid)
                } else {
                    Button("編集") {
                        enterEditMode()
                    }
                }
            }
            if isEditMode {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        withAnimation { isEditMode = false }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(isEditMode)
        .alert("案件の削除", isPresented: $isShowingDeleteAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("削除する", role: .destructive) {
                modelContext.delete(project)
                dismiss()
            }
        } message: {
            Text("この案件データを完全に削除しますか？")
        }
    }
    
    //TODO:この辺の関数ここに書かず別ファイルとかに移動させたいなあ
    private func enterEditMode()
    {
        name = project.name
        brandName = project.brand?.name ?? ""
        productName = project.productName
        selectedGenre = project.brand?.genre ?? .other
        selectedStatus = project.status
        selectedType = project.projectType
        hasDuty = project.hasDuty
        deadline = project.deadline ?? Date()
        hasDeadline = project.deadline != nil
        isRange = project.isRange
        // 単日の案件は、作成時の古い開始日が残っているので締切日に揃える
        startline = project.isRange ? (project.startline ?? deadline) : deadline
        // すでに逆転して保存されている案件を補正する
        if isRange && startline > deadline { startline = deadline }
        note = project.note
        
        withAnimation { isEditMode = true }
    }
    
    // 保存時のデータ上書き
    private func updateProject()
    {
        project.name = ProjectInputRules.trimmed(name)
        project.productName = ProjectInputRules.trimmed(productName)
        project.status = selectedStatus
        project.projectType = selectedType
        project.hasDuty = hasDuty
        project.deadline = hasDeadline ? deadline : nil
        project.isRange = hasDeadline && isRange
        project.startline = hasDeadline ? startline : nil
        project.note = note
        
        let fetchedBrand = fetchOrCreateBrand(named: brandName, genre: selectedGenre)
        project.brand = fetchedBrand
        
        withAnimation { isEditMode = false }
    }
    
    private func fetchOrCreateBrand(named name: String, genre: BrandGenre) -> Brand
    {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptor = FetchDescriptor<Brand>(predicate: #Predicate { $0.name == trimmedName })
        
        if let existingBrand = try? modelContext.fetch(descriptor).first
        {
            return existingBrand
        }
        else
        {
            let newBrand = Brand(name: trimmedName, genre: genre.rawValue, note: "")
            modelContext.insert(newBrand)
            return newBrand
        }
    }
}
