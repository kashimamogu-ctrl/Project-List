//
//  CalendarCellView.swift
//  Project List
//
//  Created by 菓子間もぐ on 2026/09/26.
//

import SwiftUI

// バーの表示位置
enum ProjectBarPosition
{
    case single      // 単日
    case start       // 開始日
    case middle      // 途中
    case end         // 終了日
}

// セル描画用のデータ構造
struct CalendarProjectSegment: Identifiable
{
    let id: String
    let name: String
    let status: ProjectStatus
    let position: ProjectBarPosition
}

struct CalendarCellView: View
{
    let date: Date
    let dayNumber: Int
    let isCurrentMonth: Bool
    let isToday: Bool
    let segments: [CalendarProjectSegment]
    let onSelect: () -> Void

    var body: some View
    {
        VStack(alignment: .leading, spacing: 2)
        {
            // 日付表示
            Text("\(dayNumber)")
                .font(.system(size: 13, weight: isToday ? .bold : .regular))
                .foregroundColor(
                    isToday ? .white :
                    isCurrentMonth ? .primary : .gray.opacity(0.4)
                )
                .frame(width: 20, height: 20)
                .background(isToday ? Color.blue : Color.clear)
                .clipShape(Circle())
                .padding([.top, .leading], 3)

            // プロジェクトバーのエリア
            VStack(spacing: 2) {
                ForEach(segments.prefix(3)) { segment in
                    projectBar(for: segment)
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 75, alignment: .topLeading)
        .background(Color(.systemBackground))
        .border(Color.gray.opacity(0.25), width: 0.5)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }

    // MARK: - 帯（バー）の描画
    @ViewBuilder
    private func projectBar(for segment: CalendarProjectSegment) -> some View
    {
        HStack(spacing: 0)
        {
            if segment.position == .start || segment.position == .single
            {
                Text(segment.name)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.black.opacity(0.85))
                    .lineLimit(1)
                    .padding(.leading, 4)
            }
            Spacer(minLength: 0)
        }
        .frame(height: 16)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray4))
        .clipShape(BarCornerShape(position: segment.position))
    }
}

// 角丸制御用のShape
struct BarCornerShape: Shape
{
    let position: ProjectBarPosition

    func path(in rect: CGRect) -> Path
    {
        var corners: UIRectCorner = []

        switch position
        {
        case .single:
                corners = .allCorners
            case .start:
                corners = [.topLeft, .bottomLeft]
            case .end:
                corners = [.topRight, .bottomRight]
            case .middle:
                corners = []
        }

        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: 4, height: 4)
        )
        return Path(path.cgPath)
    }
}
