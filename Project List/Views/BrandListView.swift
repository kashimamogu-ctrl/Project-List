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
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.subText)
                        
                        Text("案件一覧から新しいブランドを入力して案件を作成すると、ここに自動で追加されます。")
                            .font(.caption)
                            .foregroundColor(AppTheme.subText)
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
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppTheme.text)
                                    
                                    GenreTag(genre: brand.genre)
                                }
                                
                                Spacer()
                                
                                Text("\(brand.projects.count) 件の案件")
                                    .font(.footnote)
                                    .foregroundColor(AppTheme.subText)
                                
                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                                    .foregroundColor(AppTheme.subText)
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
        .background(AppTheme.background)
        .navigationTitle("ブランド一覧")
        .navigationDestination(for: Brand.self) { selectedBrand in
            BrandProjectListView(brand: selectedBrand)
            .navigationDestination(for: Project.self) { project in
                ProjectDetailView(project: project)
            }
        }
    }
}
