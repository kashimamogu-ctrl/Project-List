//  ProjectInputRules.swift
//  Project List
// 案件入力の文字数制限と入力チェック用

import SwiftUI

enum ProjectInputRules
{
    static let nameMaxLength = 30
    static let brandNameMaxLength = 20
    static let productNameMaxLength = 30

    // 前後の空白・改行を取り除く
    static func trimmed(_ text: String) -> String
    {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // 文字数が上限以内か
    static func isWithinLimit(_ text: String, maxLength: Int) -> Bool
    {
        trimmed(text).count <= maxLength
    }

    // 必須項目：空白だけではなく、上限以内か
    static func isValidRequired(_ text: String, maxLength: Int) -> Bool
    {
        !trimmed(text).isEmpty && isWithinLimit(text, maxLength: maxLength)
    }
}

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
