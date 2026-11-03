//  FormComponents.swift
//  Project List
import SwiftUI

// 「12/30」のような文字数カウンター。上限を超えたら赤字になる
struct CharacterCountText: View
{
    let text: String
    let maxLength: Int

    var body: some View
    {
        let count = ProjectInputRules.trimmed(text).count

        Text("\(count)/\(maxLength)")
            .font(.caption)
            .foregroundColor(count > maxLength ? AppTheme.accent : AppTheme.subText)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

// チェックボックス型のトグル
struct CheckboxToggleStyle: ToggleStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 8)
            {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundStyle(configuration.isOn ? AppTheme.main : AppTheme.subText)

                configuration.label
                    .foregroundColor(AppTheme.text)

                Spacer()
            }
            .frame(minHeight: AppTheme.Size.tapTarget) .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// 入力項目の見出し（「＊必須」付き）と中身をまとめる枠
struct FormField<Content: View>: View
{
    let title: String
    let isRequired: Bool
    let content: Content

    init(title: String, isRequired: Bool = false, @ViewBuilder content: () -> Content)
    {
        self.title = title
        self.isRequired = isRequired
        self.content = content()
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 6)
        {
            HStack(spacing: 4)
            {
                Text(title)
                    .font(.subheadline.weight(.semibold))

                if isRequired
                {
                    Text("＊必須")
                        .font(.caption2)
                        .foregroundColor(AppTheme.accent)
                }
            }
            content
        }
    }
}

// ドロップダウンの見た目（▼付きの枠）
struct DropdownLabel: View
{
    let text: String
    var isPlaceholder: Bool = false

    var body: some View
    {
        HStack
        {
            Text(text)
                .foregroundColor(isPlaceholder ? AppTheme.subText : AppTheme.text)
            Spacer()
            Image(systemName: "chevron.down")
                .font(.footnote)
                .foregroundColor(AppTheme.subText)
        }
        .appInputStyle()
    }
}

// ラジオボタン（◉ あり ○ なし）
struct RadioButton: View
{
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View
    {
        Button(action: action)
        {
            HStack(spacing: 6)
            {
                ZStack
                {
                    Circle()
                        .stroke(AppTheme.subText, lineWidth: AppTheme.lineWidth)
                        .frame(width: 18, height: 18)

                    if isSelected
                    {
                        Circle()
                            .fill(AppTheme.main)
                            .frame(width: 10, height: 10)
                    }
                }
                Text(title)
                    .font(.appBody)
                    .foregroundColor(AppTheme.text)
            }
            // 見た目は小さくても、タップできる範囲は44pt確保する
            .frame(minHeight: AppTheme.Size.tapTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}


// MARK: - ボタン
// メインのボタン（塗り・高さ48・角丸12）
struct PrimaryButtonStyle: ButtonStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        configuration.label
            .font(.appButton)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: AppTheme.Size.control)
            .background(AppTheme.accent.opacity(configuration.isPressed ? 0.8 : 1))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control))
            .appShadow()
    }
}

// サブのボタン（面色・高さ48・角丸12）
struct SecondaryButtonStyle: ButtonStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        configuration.label
            .font(.appButton)
            .foregroundColor(AppTheme.accent)
            .frame(maxWidth: .infinity, minHeight: AppTheme.Size.control)
            .background(AppTheme.surface.opacity(configuration.isPressed ? 0.7 : 1))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control))
    }
}

// 右下の＋ボタン（ピンクの丸）
struct FloatingAddButton: View
{
    let action: () -> Void

    var body: some View
    {
        Button(action: action)
        {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 52, height: 52)
                .background(AppTheme.main)
                .clipShape(Circle())
                .appShadow()
        }
        .accessibilityLabel("新規作成")
    }
}

// 削除ボタン（白いカードに赤い文字）
struct DeleteButton: View
{
    let title: String
    let action: () -> Void

    var body: some View
    {
        Button(role: .destructive, action: action)
        {
            HStack
            {
                Spacer()
                Image(systemName: "trash")
                Text(title)
                Spacer()
            }
            .font(.appButton)
            .foregroundColor(.red)
            .frame(minHeight: AppTheme.Size.control)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}

// 絞り込みのチップ（すべて・応募済…）
struct FilterChip: View
{
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View
    {
        Button(action: action)
        {
            Text(title)
                .font(isSelected ? .appButton : .appBody)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? AppTheme.main : AppTheme.surface)
                .foregroundColor(isSelected ? .white : AppTheme.subText)
                .clipShape(Capsule())
                // 見た目は小さくても、タップできる範囲は44pt確保する
                .frame(minHeight: AppTheme.Size.tapTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 入力欄

extension View
{
    // 入力欄の見た目（白・高さ48・角丸12・線の枠。影は付けない）
    func appInputStyle() -> some View
    {
        self
            .padding(.horizontal, 12)
            .frame(minHeight: AppTheme.Size.control)
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.control)
                    .stroke(AppTheme.line, lineWidth: AppTheme.lineWidth)
            )
    }
}

// MARK: - 部品の見本帳（Preview で全部まとめて確認する用）

#Preview("部品の見本帳")
{
    ScrollView
    {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.section)
        {
            Text("ボタン").font(.appSection)
            Button("保存する") {}.buttonStyle(PrimaryButtonStyle())
            Button("キャンセル") {}.buttonStyle(SecondaryButtonStyle())
            FloatingAddButton {}
            
            Text("進捗バッジ").font(.appSection)
            HStack
            {
                ForEach(ProjectStatus.allCases) { status in
                    StatusBadge(status: status)
                }
            }

            Text("チップ").font(.appSection)
            HStack
            {
                FilterChip(title: "すべて", isSelected: true) {}
                FilterChip(title: "応募済", isSelected: false) {}
            }

            Text("入力欄").font(.appSection)
            FormField(title: "案件名", isRequired: true)
            {
                TextField("例) 新作リップ X投稿", text: .constant(""))
                    .appInputStyle()
                CharacterCountText(text: "", maxLength: 30)
            }
            DropdownLabel(text: "選択してください", isPlaceholder: true)
            HStack(spacing: 24)
            {
                RadioButton(title: "あり", isSelected: true) {}
                RadioButton(title: "なし", isSelected: false) {}
            }
            Toggle("期間で指定する", isOn: .constant(true))
                .toggleStyle(CheckboxToggleStyle())
        }
        .padding(AppTheme.Spacing.screen)
    }
    .background(AppTheme.background)
    .fontDesign(.rounded)
    .foregroundStyle(AppTheme.text)
}

extension View
{
    // Form（設定画面のような一覧）の背景をトンマナに合わせる
    func appFormStyle() -> some View
    {
        self
            .scrollContentBackground(.hidden)   // Form 標準のグレーの背景を消す
            .background(AppTheme.background)
    }
}
