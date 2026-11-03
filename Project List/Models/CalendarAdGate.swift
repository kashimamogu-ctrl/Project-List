//  CalendarAdGate.swift
//  Project List
//  カレンダーを開いたときの「1日1回の広告」を管理する
//  今はダミーの広告。あとで AdMob のインタースティシャル広告に差し替える

import Foundation
import Network
import Observation

@MainActor
@Observable
final class CalendarAdGate
{
    enum State
    {
        case checking    // 広告を読み込み中
        case showingAd   // 広告を表示中
        case offline     // ネットにつながっていない
        case ready       // カレンダーを使える
    }

    private(set) var state: State = .checking

    // 広告の読み込みを待つ最大の時間
    private let loadTimeout: Duration = .seconds(5)
    // 最後に広告を出した日を保存しておくキー
    private static let lastShownKey = "calendarAdLastShownDay"

    // ネットにつながっているかを調べる仕組み
    private let monitor = NWPathMonitor()
    private var isLoading = false

    init()
    {
        monitor.start(queue: DispatchQueue(label: "CalendarAdGate.network"))
    }

    // カレンダーのタブを開いたときに呼ぶ
    func calendarDidOpen()
    {
        // 読み込み中に何度も呼ばれたときは、何もしない
        guard !isLoading else { return }

        // 今日すでに広告を出していれば、そのまま使える
        if hasShownToday
        {
            state = .ready
            return
        }

        // ネットにつながっていなければ、案内を出す
        guard monitor.currentPath.status == .satisfied else
        {
            state = .offline
            return
        }

        state = .checking
        isLoading = true

        Task
        {
            let loaded = await loadAd()
            isLoading = false

            // 読み込めたら広告を出す
            // 広告がない・5秒たったときは、そのまま使える（今日見た扱いにはしない）
            state = loaded ? .showingAd : .ready
        }
    }

    // 広告を閉じたときに呼ぶ（途中で閉じても、その日はもう出さない）
    func adDidClose()
    {
        UserDefaults.standard.set(Self.dayKey(for: Date()), forKey: Self.lastShownKey)
        state = .ready
    }

    // 今日すでに広告を出したか
    private var hasShownToday: Bool
    {
        UserDefaults.standard.string(forKey: Self.lastShownKey) == Self.dayKey(for: Date())
    }

    // 「2026-11-4」のような日付の文字列（日付が変わったかの判定に使う）
    static func dayKey(for date: Date) -> String
    {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)"
    }

    // 広告を読み込む（5秒たっても読み込めなければ false）
    private func loadAd() async -> Bool
    {
        let timeout = loadTimeout

        return await withTaskGroup(of: Bool.self) { group in
            // 広告の読み込み
            group.addTask { await Self.loadDummyAd() }
            // 5秒のタイマー
            group.addTask {
                try? await Task.sleep(for: timeout)
                return false
            }

            // 先に終わった方の結果を使う
            let result = await group.next() ?? false
            group.cancelAll()
            return result
        }
    }

    // ダミーの広告の読み込み（1秒かかって、必ず成功する）
    // AdMob をつなぐときに、ここを本物の読み込みに差し替える
    private nonisolated static func loadDummyAd() async -> Bool
    {
        try? await Task.sleep(for: .seconds(1))
        return true
    }
}
