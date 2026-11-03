//  ModalComponents.swift
//  Project List
//  ポップアップ（モーダル）まわりの共通部品

import SwiftUI

// ポップアップの後ろの暗い背景（タップすると閉じる）
struct ModalBackdrop: View
{
    let onTap: () -> Void

    var body: some View
    {
        // 真っ黒ではなく、本文の色を使ってやわらかく暗くする
        AppTheme.text.opacity(0.35)
            .ignoresSafeArea()
            .onTapGesture(perform: onTap)
    }
}

// ポップアップの閉じるボタン（×）
struct ModalCloseButton: View
{
    let action: () -> Void

    var body: some View
    {
        Button(action: action)
        {
            Image(systemName: "xmark.circle.fill")
                .font(.title3)
                .foregroundColor(AppTheme.subText.opacity(0.5))
                .frame(width: AppTheme.Size.tapTarget, height: AppTheme.Size.tapTarget)
        }
        .accessibilityLabel("閉じる")
    }
}

extension View
{
    // ポップアップ本体の見た目（白・角丸16・少し強めの影）
    func modalCardStyle() -> some View
    {
        self
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large))
            .shadow(color: AppTheme.shadow, radius: 12, x: 0, y: 6)
    }
}

extension View
{
    // 削除の確認アラート（ボタンの色は iOS 標準の青のまま）
    func deleteAlert(
        _ title: String,
        isPresented: Binding<Bool>,
        message: String,
        onDelete: @escaping () -> Void
    ) -> some View
    {
        // アラートだけ別の場所に付けて、そこにだけ青を指定する
        // （画面全体のピンクの tint の影響を受けないようにするため）
        background {
            Color.clear
                .alert(title, isPresented: isPresented) {
                    Button("キャンセル", role: .cancel) {}
                    Button("削除する", role: .destructive, action: onDelete)
                } message: {
                    Text(message)
                }
                .tint(.blue)
        }
    }
}
