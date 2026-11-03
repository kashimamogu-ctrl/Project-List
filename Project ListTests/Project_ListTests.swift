import Testing
import Foundation
@testable import Project_List

// テスト用に日付を作る
private func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date
{
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
}

private var thisYear: Int
{
    Calendar.current.component(.year, from: Date())
}

// 入力チェック
struct ProjectInputRulesTests
{
    @Test("前後の空白を取り除く")
    func trimsWhitespace()
    {
        #expect(ProjectInputRules.trimmed("  リップ  ") == "リップ")
    }

    @Test("空白だけの必須項目はNG")
    func rejectsBlankRequired()
    {
        #expect(!ProjectInputRules.isValidRequired("   ", maxLength: 30))
    }

    @Test("上限ちょうどはOK、1文字超えるとNG")
    func checksMaxLength()
    {
        let thirty = String(repeating: "あ", count: 30)
        #expect(ProjectInputRules.isValidRequired(thirty, maxLength: 30))
        #expect(!ProjectInputRules.isValidRequired(thirty + "あ", maxLength: 30))
    }
}

// 日付の表示
struct DateFormatTests
{
    @Test("今年の日付は「9/23」")
    func thisYearShowsMonthAndDay()
    {
        #expect(makeDate(thisYear, 9, 23).shortDateText == "9/23")
    }

    @Test("今年以外は年も表示")
    func otherYearShowsYear()
    {
        #expect(makeDate(thisYear + 1, 9, 23).shortDateText == "\(thisYear + 1)/9/23")
    }
}

// 期限の表示
struct DeadlineTextTests
{
    @Test("期限なしは表示しない")
    func noDeadline()
    {
        #expect(Project(name: "A").deadlineText == nil)
    }

    @Test("単日は「〜 9/30」")
    func singleDay()
    {
        let project = Project(name: "A", deadline: makeDate(thisYear, 9, 30))
        #expect(project.deadlineText == "〜 9/30")
    }

    @Test("期間は「9/23 〜 9/30」")
    func range()
    {
        let project = Project(
            name: "A",
            isRange: true,
            startline: makeDate(thisYear, 9, 23),
            deadline: makeDate(thisYear, 9, 30)
        )
        #expect(project.deadlineText == "9/23 〜 9/30")
    }

    @Test("開始日と締切日が同じ日なら単日表示")
    func sameDayRange()
    {
        let day = makeDate(thisYear, 9, 30)
        let project = Project(name: "A", isRange: true, startline: day, deadline: day)
        #expect(project.deadlineText == "〜 9/30")
    }
}

// カレンダーのバーの位置
struct BarPositionTests
{
    let project = Project(
        name: "A",
        isRange: true,
        startline: makeDate(2026, 9, 23),
        deadline: makeDate(2026, 9, 25)
    )

    @Test("開始日・途中・終了日")
    func positionsInRange()
    {
        #expect(project.barPosition(for: makeDate(2026, 9, 23)) == .start)
        #expect(project.barPosition(for: makeDate(2026, 9, 24)) == .middle)
        #expect(project.barPosition(for: makeDate(2026, 9, 25)) == .end)
    }

    @Test("期間の外は表示しない")
    func outOfRange()
    {
        #expect(project.barPosition(for: makeDate(2026, 9, 22)) == nil)
        #expect(project.barPosition(for: makeDate(2026, 9, 26)) == nil)
    }
}

// 保存方式
struct StoredOptionTests
{
    @Test("新しいキーで読める")
    func readsNewKey()
    {
        #expect(ProjectStatus.fromStored("progress") == .progress)
    }

    @Test("以前の日本語のデータも読める")
    func readsOldLabel()
    {
        #expect(ProjectStatus.fromStored("進行中") == .progress)
    }

    @Test("知らない値は読めない")
    func rejectsUnknown()
    {
        #expect(ProjectStatus.fromStored("???") == nil)
    }
}

// 「〇〇月の残りの案件」に出るかどうか
struct OverlapsMonthTests
{
    let september = makeDate(2026, 9, 1)
    let october = makeDate(2026, 10, 1)

    @Test("期限がその月の単日案件は出る")
    func singleDayInMonth()
    {
        let project = Project(name: "A", deadline: makeDate(2026, 9, 15))
        #expect(project.overlaps(month: september))
        #expect(!project.overlaps(month: october))
    }

    @Test("月をまたぐ期間の案件は両方の月に出る")
    func rangeAcrossMonths()
    {
        let project = Project(
            name: "A",
            isRange: true,
            startline: makeDate(2026, 9, 28),
            deadline: makeDate(2026, 10, 3)
        )
        #expect(project.overlaps(month: september))
        #expect(project.overlaps(month: october))
    }

    @Test("期限なしの案件は出ない")
    func noDeadline()
    {
        #expect(!Project(name: "A").overlaps(month: september))
    }

    @Test("月末の日の案件も、その月に出る")
    func lastDayOfMonth()
    {
        let project = Project(name: "A", deadline: makeDate(2026, 9, 30))
        #expect(project.overlaps(month: september))
        #expect(!project.overlaps(month: october))
    }
}

// カレンダーの「＋N」の計算
struct CalendarWeekLayoutTests
{
    // 2026/9/21（月）〜 9/27（日）の1週間
    let days = (0..<7).map { offset in
        CalendarDay(
            date: Calendar.current.date(byAdding: .day, value: offset, to: makeDate(2026, 9, 21))!,
            isCurrentMonth: true,
            dayNumber: 21 + offset
        )
    }

    // 9/23（週の3日目）が期日の単日案件
    private func projectOn23rd() -> Project
    {
        Project(name: "単日", deadline: makeDate(2026, 9, 23))
    }

    @Test("同じ日に3件までは「＋N」が出ない")
    func noOverflowUpToThree()
    {
        let layout = CalendarWeekLayout(days: days, projects: (0..<3).map { _ in projectOn23rd() })
        #expect(layout.bars.count == 3)
        #expect(layout.hiddenCounts.allSatisfy { $0 == 0 })
    }

    @Test("同じ日に4件なら、2本表示して「+2」")
    func overflowWithFour()
    {
        let layout = CalendarWeekLayout(days: days, projects: (0..<4).map { _ in projectOn23rd() })
        #expect(layout.bars.count == 2)
        #expect(layout.hiddenCounts[2] == 2)
    }

    @Test("長い案件は1週間ずっと見えて、混んでいる日だけ「＋N」")
    func longProjectStaysVisible()
    {
        let long = Project(
            name: "長い",
            isRange: true,
            startline: makeDate(2026, 9, 21),
            deadline: makeDate(2026, 9, 27)
        )
        let shorts = (0..<3).map { _ in
            Project(
                name: "短い",
                isRange: true,
                startline: makeDate(2026, 9, 21),
                deadline: makeDate(2026, 9, 22)
            )
        }

        let layout = CalendarWeekLayout(days: days, projects: [long] + shorts)

        #expect(layout.bars.contains { $0.name == "長い" && $0.startIndex == 0 && $0.endIndex == 6 })
        #expect(layout.hiddenCounts == [2, 2, 0, 0, 0, 0, 0])
    }
}
