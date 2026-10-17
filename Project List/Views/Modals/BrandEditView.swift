//  BrandEditView.swift
//  Project List
// ブランドの編集

import SwiftUI
import SwiftData

struct BrandEditView: View
{
    @Environment(\.dismiss) private var dismiss
    @Query private var brands: [Brand]

    let brand: Brand

    @State private var name: String = ""
    @State private var genre: BrandGenre = .other
    @State private var note: String = ""

    // 同じ名前の別ブランドがあるか
    private var isDuplicateName: Bool
    {
        let trimmedName = ProjectInputRules.trimmed(name)
        return brands.contains { $0.id != brand.id && $0.name == trimmedName }
    }

    private var isValid: Bool
    {
        ProjectInputRules.isValidRequired(name, maxLength: ProjectInputRules.brandNameMaxLength)
        && !isDuplicateName
    }

    var body: some View
    {
        NavigationStack
        {
            Form
            {
                Section("ブランド名")
                {
                    TextField("ブランド名を入力", text: $name)
                    CharacterCountText(text: name, maxLength: ProjectInputRules.brandNameMaxLength)

                    if isDuplicateName
                    {
                        Text("同じ名前のブランドがあります")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                Section("ジャンル")
                {
                    Picker("ジャンル", selection: $genre)
                    {
                        ForEach(BrandGenre.allCases) { item in
                            Text(item.label).tag(item)
                        }
                    }
                }

                Section("メモ")
                {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("ブランドの編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement: .cancellationAction)
                {
                    Button("キャンセル") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction)
                {
                    Button("保存") { saveBrand() }
                        .disabled(!isValid)
                }
            }
            .onAppear
            {
                name = brand.name
                genre = brand.genre
                note = brand.note
            }
        }
    }

    private func saveBrand()
    {
        brand.name = ProjectInputRules.trimmed(name)
        brand.genre = genre
        brand.note = note
        dismiss()
    }
}
