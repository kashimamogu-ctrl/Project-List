//  DummyAdView.swift
//  Project List
//  ダミーの広告画面（AdMob をつなぐまでの仮のもの）

import SwiftUI

struct DummyAdView: View
{
    let onClose: () -> Void

    var body: some View
    {
        ZStack(alignment: .topTrailing)
        {
            VStack(spacing: AppTheme.Spacing.item)
            {
                Text("広告（ダミー）")
                    .font(.appTitle)
                Text("ここに本物の広告が表示されます")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.subText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.surface)

            ModalCloseButton(action: onClose)
                .padding()
        }
    }
}
