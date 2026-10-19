//　ブランド一覧画面

import SwiftUI
import SwiftData

struct BrandListView: View
{
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Brand.name, order: .forward) private var brands: [Brand]
    
    var body: some View
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
                            HStack(spacing: 12)
                            {
                                VStack(alignment: .leading, spacing: 6)
                                {
                                    Text(brand.name)
                                        .font(.body)
                                        .bold()
                                        .foregroundColor(.primary)
                                    
                                    Text(brand.genre.label)
                                        .font(.caption2)
                                        .bold()
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(AppTheme.genreTagBackground)
                                        .foregroundColor(.secondary)
                                        .cornerRadius(AppTheme.tagCornerRadius)
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
                            .padding()
                            .cardStyle()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("ブランド一覧")
        .navigationDestination(for: Brand.self) { selectedBrand in
            BrandProjectListView(brand: selectedBrand)
            .navigationDestination(for: Project.self) { project in
                ProjectDetailView(project: project)
            }
        }
    }
}
