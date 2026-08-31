//
//  ProjectDetailView.swift
//  Project List
//
//  Created by 菓子間もぐ　on 2026/09/23.
//

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
    @State private var note: String = ""
    
    // 削除用のアラート管理
    @State private var isShowingDeleteAlert = false
    
    // バリデーション：必須項目が埋まっているか
    private var isValid: Bool
    {
        !name.isEmpty && !brandName.isEmpty
    }
    
    var body: some View
    {
        Form
        {
            if isEditMode
            {
                Section(header: Text("基本情報の編集")) {
                    editableSection(title: "案件名", isRequired: true) {
                        TextField("案件名を入力", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    editableSection(title: "ブランド名", isRequired: true) {
                        TextField("ブランド名を入力", text: $brandName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    editableSection(title: "商品名", isRequired: false) {
                        TextField("商品名を入力", text: $productName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    editableSection(title: "ブランドジャンル", isRequired: true) {
                        Menu {
                            ForEach(BrandGenre.allCases) { genre in
                                Button(genre.rawValue) { selectedGenre = genre }
                            }
                        } label: {
                            dropdownLabel(text: selectedGenre.rawValue)
                        }
                    }
                }
                
                Section(header: Text("ステータスと条件の編集")) {
                    editableSection(title: "進捗", isRequired: false) {
                        Menu {
                            ForEach(ProjectStatus.allCases) { status in
                                Button(status.rawValue) { selectedStatus = status }
                            }
                        } label: {
                            dropdownLabel(text: selectedStatus.rawValue)
                        }
                    }
                    
                    editableSection(title: "案件タイプ", isRequired: false) {
                        Menu {
                            ForEach(ProjectType.allCases) { type in
                                Button(type.rawValue) { selectedType = type }
                            }
                        } label: {
                            dropdownLabel(text: selectedType.rawValue)
                        }
                    }
                    
                    editableSection(title: "投稿義務", isRequired: false) {
                        HStack(spacing: 24) {
                            radioButton(title: "あり", isSelected: hasDuty) { hasDuty = true }
                            radioButton(title: "なし", isSelected: !hasDuty) { hasDuty = false }
                        }
                    }
                    
                    editableSection(title: "期限", isRequired: false) {
                        DatePicker("", selection: $deadline, displayedComponents: .date)
                            .labelsHidden()
                    }
                }
                
                Section(header: Text("メモの編集")) {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }
                
            }
            else
            {
                Section(header: Text("基本情報")) {
                    LabeledContent("ブランド名") { Text(project.brand?.name ?? "未設定").bold() }
                    LabeledContent("ジャンル") { Text(project.brand?.genre.rawValue ?? "その他") }
                    LabeledContent("案件名") { Text(project.name) }
                    if !project.productName.isEmpty {
                        LabeledContent("商品名") { Text(project.productName) }
                    }
                }
                
                Section(header: Text("ステータスと条件")) {
                    HStack {
                        Text("進捗")
                        Spacer()
                        Text(project.status.rawValue)
                            .font(.caption).bold()
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(project.status.backgroundColor)
                            .foregroundColor(project.status.foregroundColor)
                            .cornerRadius(4)
                    }
                    LabeledContent("案件タイプ") { Text(project.projectType.rawValue) }
                    HStack {
                        Text("投稿義務")
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: project.hasDuty ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(project.hasDuty ? .blue : .gray)
                            Text(project.hasDuty ? "あり" : "なし")
                        }
                    }
                    if let deadline = project.deadline
                    {
                        LabeledContent("期限")
                        {
                            Text(deadline, format: .dateTime.year().month().day())
                        }
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
        note = project.note
        
        withAnimation { isEditMode = true }
    }
    
    // 保存時のデータ上書き
    private func updateProject()
    {
        project.name = name
        project.productName = productName
        project.status = selectedStatus
        project.projectType = selectedType
        project.hasDuty = hasDuty
        project.deadline = deadline
        project.note = note
        
        let fetchedBrand = fetchOrCreateBrand(named: brandName, genre: selectedGenre)
        project.brand = fetchedBrand
        
        withAnimation { isEditMode = false }
    }
    
    private func fetchOrCreateBrand(named name: String, genre: BrandGenre) -> Brand {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptor = FetchDescriptor<Brand>(predicate: #Predicate { $0.name == trimmedName })
        
        if let existingBrand = try? modelContext.fetch(descriptor).first {
            existingBrand.genre = genre
            return existingBrand
        } else {
            let newBrand = Brand(name: trimmedName, genre: genre.rawValue, note: "")
            modelContext.insert(newBrand)
            return newBrand
        }
    }
    
    //　共通UIコンポーネント群
    private func editableSection<Content: View>(title: String, isRequired: Bool, @ViewBuilder content: () -> Content) -> some View
    {
        VStack(alignment: .leading, spacing: 6)
        {
            HStack(spacing: 4) {
                Text(title).font(.caption).foregroundColor(.gray)
                if isRequired { Text("＊必須").font(.caption2).bold().foregroundColor(.red)
                }
            }
            content()
        }
    }
    
    private func dropdownLabel(text: String) -> some View {HStack {Text(text).foregroundColor(.primary)
        Spacer()
        Image(systemName: "chevron.down").font(.footnote).foregroundColor(.gray)}.padding(8).background(Color(.systemBackground)).overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.systemGray4), lineWidth: 0.5))}
    
    private func radioButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {Button(action: action) {HStack(spacing: 6) {ZStack {Circle().stroke(Color.gray, lineWidth: 1.5).frame(width: 18, height: 18)
        
        if isSelected { Circle().fill(Color.secondary).frame(width: 10, height: 10) }}
        Text(title).font(.body).foregroundColor(.primary)}}.buttonStyle(.plain)}}

    extension Date
    {
        var localizedYMD: String {
            let formatter = DateFormatter()
            // 端末の設定（日本なら日本、アメリカならアメリカ）の「年月日」スタイルを自動採用
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: self)
    }
}
