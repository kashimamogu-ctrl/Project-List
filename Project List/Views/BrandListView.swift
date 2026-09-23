//
//  BrandVIew.swift
//  Project List
//
//  Created by 菓子間もぐ on 2026/09/20.
//　ブランド一覧画面

import SwiftUI
import SwiftData

struct BrandListView: View
{
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Brand.name, order: .forward) private var brands: [Brand]
    
    var body: some View
    {
        NavigationStack
        {
            ScrollView
            {
                VStack(spacing: 16)
                {
                    if brands.isEmpty
                    {
                        VStack(spacing: 8)
                        {
                            Text("ブランドがありません")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.secondary)
                            
                            Text("案件一覧から新しいブランドを入力して案件を作成すると、ここに自動で追加されます。")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.top, 100)
                        
                    }
                    else
                    {
                        ForEach(brands)
                        { brand in
                            NavigationLink(value: brand)
                            {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 6)
                                    {
                                        Text(brand.name)
                                            .font(.body)
                                            .bold()
                                            .foregroundColor(.primary)
                                        
                                        Text(brand.genre.rawValue)
                                            .font(.caption2)
                                            .bold()
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.gray.opacity(0.1))
                                            .foregroundColor(.secondary)
                                            .cornerRadius(4)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(brand.projects.count) 件の案件")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
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
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGray6))
            .navigationTitle("ブランド一覧")
            .navigationDestination(for: Brand.self) { selectedBrand in
                BrandProjectListView(brand: selectedBrand)
            }
        }
    }
}
