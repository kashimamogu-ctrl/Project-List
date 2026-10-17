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
    private let barSideInset: CGFloat = 3
    private let maxBarLanes = 3
    // あふれた日に「＋N」を出す段（0始まりなので3段目）
    private var overflowLane: Int { maxBarLanes - 1 }
    
    var body: some View
    {
        GeometryReader { geometry in
            let cellWidth = geometry.size.width / 7
            let layout = weekLayout
            
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
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.primary.opacity(0.85))
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
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(.trailing, 4)
                            .frame(
                                width: cellWidth - barSideInset * 2,
                                height: barHeight,
                                alignment: .trailing
                            )
                            .allowsHitTesting(false)
                            .position(
                                x: cellWidth * (CGFloat(index) + 0.5),
                                y: laneCenterY(overflowLane)
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

    // この週に表示するバーと「＋N」の数を作る
    private var weekLayout: WeekLayout
    {
        // 1. この週に表示期間がかかる案件を集める
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

        // 左から順に並べる（開始日が同じなら、期間が長い方を上の段にする）
        candidates.sort {
            if $0.start == $1.start {
                return $0.end > $1.end
            }
            return $0.start < $1.start
        }

        // 2. 段数の上限なしで、左から順に段を割り当てる
        var laneEndIndices: [Int] = []
        var assignments: [LaneAssignment] = []

        for candidate in candidates
        {
            let lane = laneEndIndices.firstIndex {
                $0 < candidate.start
            } ?? laneEndIndices.count

            if lane == laneEndIndices.count {
                laneEndIndices.append(candidate.end)
            } else {
                laneEndIndices[lane] = candidate.end
            }

            assignments.append(
                LaneAssignment(
                    project: candidate.project,
                    startIndex: candidate.start,
                    endIndex: candidate.end,
                    lane: lane
                )
            )
        }

        // 3. 4段目以降の案件がある日を「あふれた日」とする
        let isOverflowDay = days.indices.map { index in
            assignments.contains { $0.lane >= maxBarLanes && $0.covers(index) }
        }

        // 4. 描画するバーを作る
        var bars: [WeekProjectBar] = []

        for assignment in assignments
        {
            if assignment.lane < overflowLane
            {
                // 1〜2段目は常にそのまま描く
                if let bar = makeBar(
                    for: assignment,
                    from: assignment.startIndex,
                    to: assignment.endIndex
                ) {
                    bars.append(bar)
                }
            }
            else if assignment.lane == overflowLane
            {
                // 3段目は、あふれた日を避けて区切って描く
                var segmentStart: Int? = nil

                for index in assignment.startIndex...assignment.endIndex
                {
                    if !isOverflowDay[index] {
                        if segmentStart == nil {
                            segmentStart = index
                        }
                    } else if let start = segmentStart {
                        if let bar = makeBar(for: assignment, from: start, to: index - 1) {
                            bars.append(bar)
                        }
                        segmentStart = nil
                    }
                }

                if let start = segmentStart,
                   let bar = makeBar(for: assignment, from: start, to: assignment.endIndex)
                {
                    bars.append(bar)
                }
            }
            // 4段目以降はバーを描かず、「＋N」に数える
        }

        // 5. あふれた日の「＋N」の数 ＝ その日の案件数 − 1〜2段目に見えている数
        let hiddenCounts = days.indices.map { index -> Int in
            guard isOverflowDay[index] else {
                return 0
            }

            let totalCount = assignments.filter { $0.covers(index) }.count
            let visibleCount = assignments.filter {
                $0.lane < overflowLane && $0.covers(index)
            }.count

            return totalCount - visibleCount
        }

        return WeekLayout(bars: bars, hiddenCounts: hiddenCounts)
    }

    // 指定した範囲（segmentStart〜segmentEnd）のバーを作る
    private func makeBar(
        for assignment: LaneAssignment,
        from segmentStart: Int,
        to segmentEnd: Int
    ) -> WeekProjectBar?
    {
        guard
            let firstPosition = assignment.project.barPosition(
                for: days[assignment.startIndex].date
            ),
            let lastPosition = assignment.project.barPosition(
                for: days[assignment.endIndex].date
            )
        else {
            return nil
        }

        // 案件そのものがこの週で始まる・終わるか
        let beginsInThisWeek =
            firstPosition == .start || firstPosition == .single
        let endsInThisWeek =
            lastPosition == .end || lastPosition == .single

        // あふれた日で区切られた端は、角を丸めない
        let roundsLeft = segmentStart == assignment.startIndex && beginsInThisWeek
        let roundsRight = segmentEnd == assignment.endIndex && endsInThisWeek

        let barPosition: ProjectBarPosition

        if roundsLeft && roundsRight {
            barPosition = .single
        } else if roundsLeft {
            barPosition = .start
        } else if roundsRight {
            barPosition = .end
        } else {
            barPosition = .middle
        }

        return WeekProjectBar(
            // 同じ案件が1週の中で2本に分かれることがあるので、開始位置もIDに含める
            id: "\(assignment.project.id.hashValue)-\(segmentStart)",
            name: assignment.project.name,
            startIndex: segmentStart,
            endIndex: segmentEnd,
            lane: assignment.lane,
            position: barPosition,
            status: assignment.project.status
        )
    }
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
