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
            .foregroundColor(count > maxLength ? .red : .gray)
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
                    .foregroundStyle(configuration.isOn ? Color.accentColor : Color.secondary)

                configuration.label
                    .foregroundColor(.primary)

                Spacer()
            }
            .contentShape(Rectangle())
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
                    .font(.subheadline)
                    .bold()

                if isRequired
                {
                    Text("＊必須")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.red)
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
                .foregroundColor(isPlaceholder ? .gray : .primary)
            Spacer()
            Image(systemName: "chevron.down")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(10)
        .background(AppTheme.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
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
                        .stroke(Color.gray, lineWidth: 1.5)
                        .frame(width: 18, height: 18)

                    if isSelected
                    {
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
}
