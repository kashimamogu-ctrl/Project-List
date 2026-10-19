//  ProfileEditView.swift
//  Project List
import SwiftUI
import SwiftData

struct ProfileEditView: View
{
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let profile: UserProfile?
    
    @State private var name = ""
    @State private var heightText = ""
    @State private var weightText = ""
    @State private var boneType = ""
    @State private var personalColor = ""
    @State private var faceType = ""
    @State private var selectedSkinTypes: Set<String> = []
    @State private var accountIDs: [String: String] = [:]
    @State private var accountURLs: [String: String] = [:]
    
    private let idPlatforms = ["X", "Instagram", "TikTok", "LIPS", "@cosme"]
    private let urlPlatforms = ["X", "Instagram", "YouTube"]
    private let allPlatforms = ["X", "Instagram", "TikTok", "LIPS", "@cosme", "YouTube"]
    private let skinTypeOptions = [
        "乾燥肌",
        "脂性肌",
        "混合肌",
        "普通肌",
        "敏感肌"
    ]
    
    var body: some View
    {
        NavigationStack
        {
            Form
            {
                Section("基本情報")
                {
                    HStack {
                        Text("名前")

                        Spacer()

                        TextField("入力", text: $name)
                            .inputBoxStyle()
                    }
                }
                
                Section("美容情報")
                {
                    HStack {
                        Text("身長")

                        Spacer()

                        TextField("入力", text: $heightText)
                            .keyboardType(.decimalPad)
                            .inputBoxStyle()

                        Text("cm")
                    }

                    HStack {
                        Text("体重")

                        Spacer()

                        TextField("入力", text: $weightText)
                            .keyboardType(.decimalPad)
                            .inputBoxStyle()
                        
                        Text("kg")
                    }

                    HStack {
                        Text("骨格タイプ")

                        Spacer()

                        selectionMenu(
                            selection: $boneType,
                            options: ["ストレート", "ウェーブ", "ナチュラル"],
                            width: 130
                        )
                    }

                    HStack {
                        Text("パーソナルタイプ")

                        Spacer()

                        selectionMenu(
                            selection: $personalColor,
                            options: ["イエベ春", "ブルベ夏", "イエベ秋", "ブルベ冬"],
                            width: 130
                        )
                    }
                    
                    HStack {
                        Text("顔タイプ")

                        Spacer()

                        selectionMenu(
                            selection: $faceType,
                            options: [
                                "キュート",
                                "アクティブキュート",
                                "フレッシュ",
                                "クールカジュアル",
                                "フェミニン",
                                "クール",
                                "エレガント",
                                "ソフトエレガント"
                            ],
                            width: 180
                        )
                    }

                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("肌タイプ")

                        LazyVGrid(
                            columns: Array(
                                repeating: GridItem(.flexible(), spacing: 6),
                                count: 3
                            ),
                            alignment: .leading,
                            spacing: 8
                        ) {
                            ForEach(skinTypeOptions, id: \.self) { type in
                                Button {
                                    if selectedSkinTypes.contains(type) {
                                        selectedSkinTypes.remove(type)
                                    } else {
                                        selectedSkinTypes.insert(type)
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(type)
                                            .font(.subheadline)
                                            .lineLimit(1)

                                        Image(
                                            systemName: selectedSkinTypes.contains(type)
                                                ? "checkmark.square.fill"
                                                : "square"
                                        )
                                        .font(.subheadline)
                                        .foregroundStyle(
                                            selectedSkinTypes.contains(type)
                                                ? Color.accentColor
                                                : Color.secondary
                                        )
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                Section("外部アカウントID") {
                    ForEach(idPlatforms, id: \.self) { platform in
                        HStack {
                            Text(platform)
                            
                            Spacer()
                            
                            TextField(
                                "IDを入力",
                                text: Binding(
                                    get: { accountIDs[platform, default: ""] },
                                    set: { accountIDs[platform] = $0 }
                                )
                            )
                            .inputBoxStyle(size: .large)
                        }
                    }
                }
                
                Section("アカウントURL") {
                    ForEach(urlPlatforms, id: \.self) { platform in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(platform)

                            TextField(
                                "https://...",
                                text: Binding(
                                    get: { accountURLs[platform, default: ""] },
                                    set: { accountURLs[platform] = $0 }
                                )
                            )
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.leading)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .padding(8)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
            .navigationTitle("プロフィール一括編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement: .cancellationAction)
                {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction)
                {
                    Button("保存") {
                        saveProfile()
                    }
                }
            }
            .onAppear {
                loadProfile()
            }
        }
    }
    
    private func loadProfile()
    {
        name = profile?.name ?? ""
        heightText = profile?.heightCm.map { $0.formatted() } ?? ""
        weightText = profile?.weightKg.map { $0.formatted() } ?? ""
        boneType = profile?.boneType ?? ""
        personalColor = profile?.personalColor ?? ""
        faceType = profile?.faceType ?? ""
        selectedSkinTypes = Set(
            (profile?.skinType ?? "")
                .split(separator: "、")
                .map { String($0) }
        )
        accountIDs = [:]
        accountURLs = [:]

        for account in profile?.externalAccounts ?? [] {
            accountIDs[account.platform] = account.accountID
            accountURLs[account.platform] = account.profileURL
        }
    }
    
    // 「160cm」「１６０」「52,5」などから数値を取り出す
    private func parseNumber(_ text: String) -> Double?
    {
        let halfWidth = text.applyingTransform(.fullwidthToHalfwidth, reverse: false) ?? text
        let filtered = halfWidth
            .replacingOccurrences(of: ",", with: ".")
            .filter { ("0"..."9").contains($0) || $0 == "." }
        return Double(filtered)
    }

    private func saveProfile()
    {
        let savedProfile = profile ?? modelContext.fetchOrCreateProfile()

        savedProfile.name = name
        savedProfile.heightCm = parseNumber(heightText)
        savedProfile.weightKg = parseNumber(weightText)
        savedProfile.boneType = boneType
        savedProfile.personalColor = personalColor
        savedProfile.faceType = faceType
        savedProfile.skinType = skinTypeOptions
            .filter { selectedSkinTypes.contains($0) }
            .joined(separator: "、")
        
        for platform in allPlatforms {
            let accountID = accountIDs[platform, default: ""]
            let profileURL = accountURLs[platform, default: ""]

            if let account = savedProfile.externalAccounts.first(
                where: { $0.platform == platform }
            ) {
                account.accountID = accountID
                account.profileURL = profileURL
            } else if !accountID.isEmpty || !profileURL.isEmpty {
                let account = ExternalAccount(
                    platform: platform,
                    accountID: accountID,
                    profileURL: profileURL,
                    profile: savedProfile
                )
                savedProfile.externalAccounts.append(account)
            }
        }

        try? modelContext.save()
        dismiss()
    }
    
    private func selectionMenu(
        selection: Binding<String>,
        options: [String],
        width: CGFloat
    ) -> some View {
        Menu {
            Button {
                selection.wrappedValue = ""
            } label: {
                if selection.wrappedValue.isEmpty {
                    Label("未選択", systemImage: "checkmark")
                } else {
                    Text("未選択")
                }
            }

            ForEach(options, id: \.self) { option in
                Button {
                    selection.wrappedValue = option
                } label: {
                    if selection.wrappedValue == option {
                        Label(option, systemImage: "checkmark")
                    } else {
                        Text(option)
                    }
                }
            }
        } label: {
            HStack {
                Text(selection.wrappedValue.isEmpty ? "未選択" : selection.wrappedValue)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .frame(width: width, height: 36, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .tint(.primary)
    }
}

private enum InputBoxSize
{
    case small
    case large

    var width: CGFloat
    {
        switch self
        {
            case .small: 130
            case .large: 200
        }
    }
}

private extension View
{
    func inputBoxStyle(size: InputBoxSize = .small) -> some View
    {
        self
            .textFieldStyle(.plain)
            .multilineTextAlignment(.leading)
            .padding(8)
            .frame(width: size.width, height: 44)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
