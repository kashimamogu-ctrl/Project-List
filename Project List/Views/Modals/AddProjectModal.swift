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
        let trimmedName = ProjectInputRules.trimmed(brandName)
        return brands.first { $0.name == trimmedName }
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
                    inputSection(title: "案件名", isRequired: true)
                    {
                        TextField("例) Apple Love様新作リップ X投稿", text: $name)
                            .textFieldStyle(.roundedBorder)
                        CharacterCountText(text: name, maxLength: ProjectInputRules.nameMaxLength)
                    }
                    
                    // ブランド名（必須）
                    inputSection(title: "ブランド名", isRequired: true)
                    {
                        TextField("例) Apple Love", text: $brandName)
                            .textFieldStyle(.roundedBorder)
                        CharacterCountText(text: brandName, maxLength: ProjectInputRules.brandNameMaxLength)
                    }
                    
                    // 商品名
                    inputSection(title: "商品名", isRequired: false)
                    {
                        TextField("例) ぽってりリップ 01 ダークチェリー", text: $productName)
                            .textFieldStyle(.roundedBorder)
                        CharacterCountText(text: productName, maxLength: ProjectInputRules.productNameMaxLength)
                    }
                    
                    // ブランドジャンル（選択）
                    inputSection(title: "ブランドジャンル", isRequired: true)
                    {
                        if let existingBrand
                        {
                            // 既存ブランドのジャンルは表示のみ（変更はブランド編集画面で）
                            customDropdownLabel(text: existingBrand.genre.rawValue, isSelected: true)
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
                                    Button(genre.rawValue)
                                    {
                                        selectedGenre = genre
                                    }
                                }
                            }label:{
                                customDropdownLabel(text: selectedGenre?.rawValue ?? "選択してください", isSelected: selectedGenre != nil)
                            }
                        }
                    }
                    
                    // 進捗（選択）
                    inputSection(title: "進捗", isRequired: false)
                    {
                        Menu
                        {
                            ForEach(ProjectStatus.allCases) { status in
                                Button(status.rawValue)
                                {
                                    selectedStatus = status
                                }
                            }
                        } label: {
                            customDropdownLabel(text: selectedStatus.rawValue, isSelected: true)
                        }
                    }
                    
                    // 案件タイプ（選択）
                    inputSection(title: "案件タイプ", isRequired: false)
                    {
                        Menu
                        {
                            ForEach(ProjectType.allCases) { type in
                                Button(type.rawValue) {
                                    selectedType = type
                                }
                            }
                        } label: {
                            customDropdownLabel(text: selectedType.rawValue, isSelected: true)
                        }
                    }
                    
                    // 投稿義務（ラジオボタン）
                    inputSection(title: "投稿義務", isRequired: false)
                    {
                        HStack(spacing: 24)
                        {
                            radioButton(title: "あり", isSelected: hasDuty)
                            {
                                hasDuty = true
                            }
                            radioButton(title: "なし", isSelected: !hasDuty)
                            {
                                hasDuty = false
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // 期限(日付型)
                    Section(header: Text("案件期限"))
                    {
                        Toggle("期限を設定する", isOn: $hasDeadline)

                        if hasDeadline
                        {
                            VStack(alignment: .leading, spacing: 8)
                            {
                                Toggle("期間で指定する", isOn: $isRange)
                                    .toggleStyle(CheckboxToggleStyle())
                                    .onChange(of: isRange) { oldValue, newValue in
                                        // 期間指定がONになった際、開始日が終了日より後なら補正
                                        if newValue && startline > deadline { startline = deadline }
                                    }

                                if isRange
                                {
                                    DatePicker("開始日", selection: $startline, displayedComponents: .date)
                                        .environment(\.locale, Locale(identifier: "ja_JP"))
                                        .onChange(of: startline) { _, newValue in
                                            handleStartDateChange(newDate: newValue)
                                        }

                                    DatePicker("終了日", selection: $deadline, displayedComponents: .date)
                                        .environment(\.locale, Locale(identifier: "ja_JP"))
                                        .onChange(of: deadline) { _, newValue in
                                            handleDeadlineChange(newDate: newValue)
                                        }
                                }
                                else
                                {
                                    DatePicker("期日", selection: $deadline, displayedComponents: .date)
                                        .environment(\.locale, Locale(identifier: "ja_JP"))
                                }
                            }
                            // 「期限を設定する」と離して、誤タップを防ぐ
                            .padding(.top, 12)
                        }
                    }
                    
                    inputSection(title: "メモ", isRequired: false)
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
    
    // 選択肢きドロップダウンの共通デザインコンポーネント
    private func customDropdownLabel(text: String, isSelected: Bool) -> some View
    {
        HStack
        {
            Text(text)
                .foregroundColor(isSelected ? .primary : .gray)
            Spacer()
            Image(systemName: "chevron.down")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(10)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    // セクションの共通枠
    private func inputSection<Content: View>(title: String, isRequired: Bool, @ViewBuilder content: () -> Content) -> some View
    {
        VStack(alignment: .leading, spacing: 6)
        {
            HStack(spacing: 4)
            {
                Text(title)
                    .font(.subheadline)
                    .bold()
                if isRequired {
                    Text("＊必須")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.red)
                }
            }
            content()
        }
    }
    
    // カスタムラジオボタン
    private func radioButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View
    {
        Button(action: action) {
            HStack(spacing: 6) {
                ZStack {
                    Circle()
                        .stroke(Color.gray, lineWidth: 1.5)
                        .frame(width: 18, height: 18)
                    if isSelected {
                        Circle()
                            .fill(Color.secondary)
                            .frame(width: 10, height: 10)
                    }
                }
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(.plain)
    }
    
    // 保存ロジック
    private func saveProject()
    {
        let fetchedBrand = fetchOrCreateBrand(named: brandName, genre: selectedGenre ?? .other)
        
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
    
    private func fetchOrCreateBrand(named name: String, genre: BrandGenre) -> Brand
    {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let descriptor = FetchDescriptor<Brand>(
            predicate: #Predicate { $0.name == trimmedName }
        )
        
        if let existingBrand = try? modelContext.fetch(descriptor).first {
            return existingBrand
        }else {
            let newBrand = Brand(
                name: trimmedName,
                genre: genre.rawValue,
                note: ""
            )
            modelContext.insert(newBrand)
            return newBrand
        }
    }
    
    // CHECK: この２つの関数統合できそう？
    // 開始日が変更された時の自動チェック
    private func handleStartDateChange(newDate: Date)
    {
        if isRange && newDate > deadline
        {
            // 開始日が終了日より後になった場合、終了日を開始日と同じにする（または自動入れ替え）
            deadline = newDate
        }
    }
    // 終了日が変更された時の自動チェック
    private func handleDeadlineChange(newDate: Date)
    {
        if isRange && newDate < startline {
            // 終了日が開開始日より前になった場合、開始日を終了日と同じにする（または自動入れ替え）
            startline = newDate
        }
    }
}
