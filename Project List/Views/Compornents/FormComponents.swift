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
