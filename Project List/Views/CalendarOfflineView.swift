//  CalendarOfflineView.swift
//  Project List
//  ネットにつながっていないときに、カレンダーの代わりに出す案内

import SwiftUI

struct CalendarOfflineView: View
{
    let onRetry: () -> Void

    var body: some View
    {
        VStack(spacing: AppTheme.Spacing.section)
        {
            Image(systemName: "wifi.slash")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.subText)

            Text("カレンダーを使うには、\nインターネットへの接続が必要です")
                .font(.subheadline)
                .multilineTextAlignment(.center)

            Button("もう一度試す", action: onRetry)
                .buttonStyle(PrimaryButtonStyle())
                .frame(width: 200)
        }
        .padding(AppTheme.Spacing.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
    }
}
