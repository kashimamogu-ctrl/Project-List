//  CalendarWeekLayout.swift
//  Project List
//  1週間分の案件バーの並べ方と「＋N」の数を計算する
//  画面の描画と切り離しているので、テストで動きを確認できる

import Foundation

// 描画する1本のバー
struct WeekProjectBar: Identifiable
{
    let id: String
    let name: String
    let startIndex: Int
    let endIndex: Int
    let lane: Int
    let position: ProjectBarPosition
    let status: ProjectStatus
}

struct CalendarWeekLayout
{
    // 1日に表示するバーは最大3段
    static let maxBarLanes = 3
    // あふれた日に「＋N」を出す段（0始まりなので3段目）
    static let overflowLane = maxBarLanes - 1

    let bars: [WeekProjectBar]
    let hiddenCounts: [Int] // 日ごとの「＋N」の数（0なら表示しない）

    init(days: [CalendarDay], projects: [Project])
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

            candidates.append((project: project, start: startIndex, end: endIndex))
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
            assignments.contains { $0.lane >= Self.maxBarLanes && $0.covers(index) }
        }

        // 4. 描画するバーを作る
        var bars: [WeekProjectBar] = []

        for assignment in assignments
        {
            if assignment.lane < Self.overflowLane
            {
                // 1〜2段目は常にそのまま描く
                if let bar = Self.makeBar(
                    for: assignment,
                    from: assignment.startIndex,
                    to: assignment.endIndex,
                    days: days
                ) {
                    bars.append(bar)
                }
            }
            else if assignment.lane == Self.overflowLane
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
                        if let bar = Self.makeBar(for: assignment, from: start, to: index - 1, days: days) {
                            bars.append(bar)
                        }
                        segmentStart = nil
                    }
                }

                if let start = segmentStart,
                   let bar = Self.makeBar(for: assignment, from: start, to: assignment.endIndex, days: days)
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
                $0.lane < Self.overflowLane && $0.covers(index)
            }.count

            return totalCount - visibleCount
        }

        self.bars = bars
        self.hiddenCounts = hiddenCounts
    }

    // 指定した範囲（segmentStart〜segmentEnd）のバーを作る
    private static func makeBar(
        for assignment: LaneAssignment,
        from segmentStart: Int,
        to segmentEnd: Int,
        days: [CalendarDay]
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

// 段を割り当てた案件（計算の途中で使うデータ）
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
