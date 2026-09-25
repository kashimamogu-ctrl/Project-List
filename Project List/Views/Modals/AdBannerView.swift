//
//  AdBannerView.swift
//  Project List
//
//  Created by 菓子間もぐ on 2026/09/25.
//

import SwiftUI

// 今はダミー表示。後でGoogle AdMobのViewに差し替える
struct AdBannerView: View
{
    var body: some View
    {
        HStack
        {
            Spacer()
            Text("広告エリア (50pt)")
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
        }
        .frame(height: 50)
        .background(Color.gray.opacity(0.1))
    }
}
