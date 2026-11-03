import SwiftUI

// セル描画用のデータ構造
struct CalendarCellView: View
{
    let date: Date
    let dayNumber: Int
    let isCurrentMonth: Bool
    let isToday: Bool
    let onSelect: () -> Void

    var body: some View
    {
        VStack(alignment: .leading, spacing: 2)
        {
            Text("\(dayNumber)")
                .font(.system(size: 13, weight: isToday ? .semibold : .regular))
                .foregroundColor(
                    isToday ? .white :
                        isCurrentMonth ? AppTheme.text : AppTheme.subText.opacity(0.5)
                )
                .frame(width: 20, height: 20)
                .background(isToday ? AppTheme.main : Color.clear)
                .clipShape(Circle())
                .padding([.top, .leading], 3)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 78, alignment: .topLeading)
        .background(AppTheme.card)
        .border(AppTheme.line, width: 0.5)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

// 1週間分の日付セルと、週をまたがない案件バーを表示するView
struct CalendarWeekRowView: View
{
    let days: [CalendarDay]
    let projects: [Project]
    let onSelectDay: (CalendarDay) -> Void
    
    private let rowHeight: CGFloat = 78
    private let barHeight: CGFloat = 16
    private let barSpacing: CGFloat = 2
    private let barSideInset: CGFloat = 3
    
    var body: some View
    {
        GeometryReader { geometry in
            let cellWidth = geometry.size.width / 7
            let layout = CalendarWeekLayout(days: days, projects: projects)
            
            ZStack(alignment: .topLeading)
            {
                // まず、日付セルを7つ横に並べる
                HStack(spacing: 0)
                {
                    ForEach(0..<days.count, id: \.self) { index in
                        let day = days[index]
                        
                        CalendarCellView(
                            date: day.date,
                            dayNumber: day.dayNumber,
                            isCurrentMonth: day.isCurrentMonth,
                            isToday: Calendar.current.isDateInToday(day.date),
                            onSelect: {
                                onSelectDay(day)
                            }
                        )
                        .frame(width: cellWidth, height: rowHeight)
                    }
                }
                
                // その上に、期間に応じた幅の案件バーを重ねる
                ForEach(layout.bars) { bar in
                    let numberOfCells = bar.endIndex - bar.startIndex + 1
                    let barWidth = cellWidth * CGFloat(numberOfCells) - barSideInset * 2
                    
                    HStack(spacing: 0)
                    {
                        Text(bar.name)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(bar.status.textColor)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .padding(.leading, 4)
                        
                        Spacer(minLength: 0)
                    }
                    .frame(width: barWidth, height: barHeight)
                    .background(bar.status.foregroundColor.opacity(0.25))
                    .clipShape(BarCornerShape(position: bar.position))
                    .allowsHitTesting(false)
                    .position(
                        x: cellWidth * (
                            CGFloat(bar.startIndex)
                            + CGFloat(numberOfCells) / 2
                        ),
                        y: laneCenterY(bar.lane)
                    )
                }
                // 表示しきれない案件がある日は、3段目に「＋N」を出す
                ForEach(days.indices, id: \.self) { index in
                    let hiddenCount = layout.hiddenCounts[index]
                    
                    if hiddenCount > 0
                    {
                        Text("+\(hiddenCount)")
                            .font(.system(size: 9, weight: .medium)) .foregroundColor(AppTheme.subText)
                            .padding(.trailing, 4)
                            .frame(
                                width: cellWidth - barSideInset * 2,
                                height: barHeight,
                                alignment: .trailing
                            )
                            .allowsHitTesting(false)
                            .position(
                                x: cellWidth * (CGFloat(index) + 0.5),
                                y:laneCenterY(CalendarWeekLayout.overflowLane)
                            )
                    }
                }
            }
            .frame(width: geometry.size.width, height: rowHeight)
        }
        .frame(height: rowHeight)
    }
    
    // 段ごとのバーの縦位置（中心）
    private func laneCenterY(_ lane: Int) -> CGFloat
    {
        32 + CGFloat(lane) * (barHeight + barSpacing)
    }
    
    // 段を割り当てた案件（描画前の中間データ）
    private struct LaneAssignment
    {
        let project: Project
        let startIndex: Int
        let endIndex: Int
        let lane: Int
        
        // 指定した日（週の中の位置）にこの案件がかかっているか
        func covers(_ index: Int) -> Bool
        {
            startIndex <= index && index <= endIndex
        }
    }
    
    // 1週間分の描画内容
    private struct WeekLayout
    {
        let bars: [WeekProjectBar]
        let hiddenCounts: [Int] // 日ごとの「＋N」の数（0なら表示しない）
    }
    
    private struct WeekProjectBar: Identifiable
    {
        let id: String
        let name: String
        let startIndex: Int
        let endIndex: Int
        let lane: Int
        let position: ProjectBarPosition
        let status: ProjectStatus
    }
    
    // バーの左右の端だけ角を丸めるShape
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
            case .middle:
                corners = []
            case .end:
                corners = [.topRight, .bottomRight]
            }
            
            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: 4, height: 4)
            )
            
            return Path(path.cgPath)
        }
    }
}
