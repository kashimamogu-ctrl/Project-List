//
//  BrandProjectListView.swift
//  Project List
//
//  Created by 菓子間もぐ on 2026/09/23.
//

import SwiftUI
import SwiftData

struct BrandProjectListView: View
{
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss // 削除後に前の画面に戻るトリガー
    
    var brand: Brand
    
    // 安全な動的削除管理用の部屋
    @State private var isShowingDeleteAlert = false
    
    var body: some View
    {
        ScrollView
        {
            VStack(spacing: 24)
            {
                //ブランドの基本情報
                VStack(alignment: .leading, spacing: 12)
                {
                    Text("ブランド情報")
                        .font(.footnote)
                        .bold()
                        .foregroundColor(.gray)
                        .padding(.horizontal, 4)
                    
                    VStack(spacing: 0)
                    {
                        infoRow(title: "ブランド名", value: brand.name, isBold: true)
                        Divider().padding(.horizontal)
                        infoRow(title: "ジャンル", value: brand.genre.rawValue, isBold: false)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                

                // このブランドに紐づく案件一覧
                VStack(alignment: .leading, spacing: 12)
                {
                    Text("\(brand.name) の案件")
                        .font(.footnote)
                        .bold()
                        .foregroundColor(.gray)
                        .padding(.horizontal, 4)
                    
                    if brand.projects.isEmpty
                    {
                        HStack
                        {
                            Spacer()
                            Text("このブランドの案件はありません")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .italic()
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                    else
                    {
                        ForEach(brand.projects)
                        { project in
                            NavigationLink(destination: ProjectDetailView(project: project))
                            {
                                HStack(spacing: 12)
                                {
                                    VStack(alignment: .leading, spacing: 4)
                                    {
                                        HStack
                                        {
                                            Text(brand.name)
                                                .font(.caption)
                                                .bold()
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.blue.opacity(0.1))
                                                .foregroundColor(.blue)
                                                .cornerRadius(4)
                                            
                                            Spacer()
                                            
                                            Text(project.status.rawValue)
                                                .font(.caption)
                                                .bold()
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(project.status.backgroundColor)
                                                .foregroundColor(project.status.foregroundColor)
                                                .cornerRadius(4)
                                        }
                                        
                                        Text(project.name)
                                            .font(.body)
                                            .bold()
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        HStack
                                        {
                                            if !project.productName.isEmpty
                                            {
                                                Text("商品: \(project.productName)")
                                                    .font(.footnote)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            if let deadline = project.deadline
                                            {
                                                Text(deadline, format: .dateTime.year().month().day())
                                                    .font(.caption2)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding(.top, 2)
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // 一番下の個別削除ボタン
                Button(role: .destructive)
                {
                    isShowingDeleteAlert = true
                } label: {
                    HStack
                    {
                        Spacer()
                        Image(systemName: "trash")
                        Text("このブランドを削除する")
                        Spacer()
                    }
                    .font(.body)
                    .bold()
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGray6))
        .navigationTitle(brand.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("ブランドの削除", isPresented: $isShowingDeleteAlert)
        {
            Button("キャンセル", role: .cancel) {}
            Button("削除する", role: .destructive)
            {
                withAnimation
                {
                    modelContext.delete(brand)
                    try? modelContext.save() //TODO：手動で無理やり削除っぽいので設計的に大丈夫か確認
                    dismiss()
                }
            }
        }
        message:
        {
            if brand.projects.isEmpty
            {
                Text("ブランド「\(brand.name)」を完全に削除しますか？")
            }
            else
            {
                Text("警告：ブランド「\(brand.name)」には \(brand.projects.count) 件の案件が紐づいています。\n\nこのブランドを削除すると、中の案件もすべて一緒に完全に消去されますが、本当によろしいですか？")
            }
        }
    }
    
    // 表示用の行コンポーネント
    private func infoRow(title: String, value: String, isBold: Bool) -> some View
    {
        HStack
        {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold(isBold)
                .foregroundColor(.primary)
        }
        .padding()
        .font(.subheadline)
    }
}


#Preview
{
    // 1. メモリ上だけに保存されるプレビュー用コンテナを作成
    let schema = Schema([Project.self, Brand.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    
    // 2. プレビュー用のデータ操作窓口（Context）を取得
    let context = container.mainContext
    
    // 3. テスト用のブランド（Brand）を生成
    let sampleBrand = Brand(
        name: "Apple Love",
        genre: BrandGenre.cosmetics.rawValue,
        note: "プレビュー用のテストブランドです"
    )
    
    // 4. そのブランドに紐づくテスト用の案件（Project）を生成
    let project1 = Project(
        name: "新作リップ X投稿案件",
        brand: sampleBrand,
        productName: "ぽってりリップ 01",
        status: .progress,
        projectType: .gifting,
        hasDuty: true,
        deadline: Date(),
        note: ""
    )
    
    let project2 = Project(
        name: "秋の新作チーク Instagram投稿",
        brand: sampleBrand,
        productName: "艶感チーク 02",
        status: .applied,
        projectType: .monitor,
        hasDuty: false,
        deadline: Date().addingTimeInterval(86400 * 3),
        note: ""
    )
    
    // 5. 生成したダミーデータをコンテキストに挿入
    context.insert(sampleBrand)
    context.insert(project1)
    context.insert(project2)
    
    // 6. ダミーデータが注入されたコンテナをViewに渡して表示
    return NavigationStack {
        BrandProjectListView(brand: sampleBrand)
    }
    .modelContainer(container)
}
