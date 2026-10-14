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
                .font(.system(size: 13, weight: isToday ? .bold : .regular))
                .foregroundColor(
                    isToday ? .white :
                    isCurrentMonth ? .primary : .gray.opacity(0.4)
                )
                .frame(width: 20, height: 20)
                .background(isToday ? Color.blue : Color.clear)
                .clipShape(Circle())
                .padding([.top, .leading], 3)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 78, alignment: .topLeading)
        .background(Color(.systemBackground))
        .border(Color.gray.opacity(0.25), width: 0.5)
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
    private let maxBarLanes = 3

    var body: some View
    {
        GeometryReader { geometry in
            let cellWidth = geometry.size.width / 7

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
                ForEach(weekBars) { bar in
                    let numberOfCells = bar.endIndex - bar.startIndex + 1
                    let barWidth = cellWidth * CGFloat(numberOfCells)

                    HStack(spacing: 0)
                    {
                        Text(bar.name)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.black.opacity(0.85))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .padding(.leading, 4)

                        Spacer(minLength: 0)
                    }
                    .frame(width: barWidth, height: barHeight)
                    .background(Color(.systemGray4))
                    .clipShape(BarCornerShape(position: bar.position))
                    .allowsHitTesting(false)
                    .position(
                        x: cellWidth * (
                            CGFloat(bar.startIndex)
                            + CGFloat(numberOfCells) / 2
                        ),
                        y: 32 + CGFloat(bar.lane) * (barHeight + barSpacing)
                    )
                }
            }
            .frame(width: geometry.size.width, height: rowHeight)
        }
        .frame(height: rowHeight)
    }

    // この週に表示する案件バーを作る
    private var weekBars: [WeekProjectBar]
    {
        var candidates: [(project: Project, start: Int, end: Int)] = []

        for project in projects
        {
            let activeIndices = days.indices.filter { index in
                project.barPosition(for: days[index].date) != nil
            }

            guard let startIndex = activeIndices.first,
                  let endIndex = activeIndices.last
            else {
                continue
            }

            candidates.append((
                project: project,
                start: startIndex,
                end: endIndex
            ))
        }

        // 左から順にバーのレーンを割り当てる
        candidates.sort {
            if $0.start == $1.start {
                return $0.end < $1.end
            }
            return $0.start < $1.start
        }

        var laneEndIndices: [Int] = []
        var result: [WeekProjectBar] = []

        for candidate in candidates
        {
            let lane = laneEndIndices.firstIndex {
                $0 < candidate.start
            } ?? laneEndIndices.count

            // 1日に表示するバーは最大3件にする
            guard lane < maxBarLanes else {
                continue
            }

            if lane == laneEndIndices.count {
                laneEndIndices.append(candidate.end)
            } else {
                laneEndIndices[lane] = candidate.end
            }

            guard
                let startPosition = candidate.project.barPosition(
                    for: days[candidate.start].date
                ),
                let endPosition = candidate.project.barPosition(
                    for: days[candidate.end].date
                )
            else{
                continue
            }

            let beginsInThisWeek =
                startPosition == .start || startPosition == .single
            let endsInThisWeek =
                endPosition == .end || endPosition == .single

            let barPosition: ProjectBarPosition

            if beginsInThisWeek && endsInThisWeek {
                barPosition = .single
            } else if beginsInThisWeek {
                barPosition = .start
            } else if endsInThisWeek {
                barPosition = .end
            } else {
                barPosition = .middle
            }

            result.append(
                WeekProjectBar(
                    id: candidate.project.id.hashValue.description,
                    name: candidate.project.name,
                    startIndex: candidate.start,
                    endIndex: candidate.end,
                    lane: lane,
                    position: barPosition
                )
            )
        }

        return result
    }
}

private struct WeekProjectBar: Identifiable
{
    let id: String
    let name: String
    let startIndex: Int
    let endIndex: Int
    let lane: Int
    let position: ProjectBarPosition
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
