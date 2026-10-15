import SwiftUI
import SwiftData
import UIKit

struct MyPageView: View
{
    @Query private var profiles: [UserProfile]
    
    @State private var isShowingProfileEdit = false
    @State private var showingCopyToast = false
    
    @Environment(\.modelContext) private var modelContext

    private var profile: UserProfile?
    {
        profiles.first
    }

    var body: some View
    {
        ScrollView
        {
            VStack(alignment: .leading, spacing: 26)
            {
                Text("マイページ")
                    .font(.title2)
                    .bold()
                
                VStack(spacing: 12)
                {
                    menuRow("アプリの使い方")
                    menuRow("各種設定")
                }
                
                VStack(alignment: .leading, spacing: 12)
                {
                    sectionTitle("基本情報", showsEdit: true)
                    infoRow("名前", value: profile?.name ?? "")
                }
                
                VStack(alignment: .leading, spacing: 12)
                {
                    sectionTitle("美容情報")
                    infoRow(
                        "身長",
                        value: measurementText(profile?.heightCm, unit: "cm")
                    )
                    infoRow(
                        "体重",
                        value: measurementText(profile?.weightKg, unit: "kg")
                    )
                    infoRow("骨格タイプ", value: profile?.boneType ?? "")
                    infoRow("パーソナルタイプ", value: profile?.personalColor ?? "")
                    infoRow("顔タイプ", value: profile?.faceType ?? "")
                    infoRow("肌タイプ", value: profile?.skinType ?? "")
                }
                
                VStack(alignment: .leading, spacing: 12)
                {
                    sectionTitle("外部アカウントID")
                    
                    ForEach(["X", "Instagram", "TikTok", "LIPS", "@cosme"], id: \.self) { platform in
                        infoRow(
                            platform,
                            value: accountValue(for: platform),
                            copyable: true
                        )
                    }
                }
                
                VStack(alignment: .leading, spacing: 12)
                {
                    sectionTitle("アカウントURL")
                    
                    ForEach(["X", "Instagram", "YouTube"], id: \.self) { platform in
                        infoRow(
                            platform,
                            value: accountValue(for: platform, isURL: true),
                            copyable: true
                        )
                    }
                }
                
                VStack(alignment: .leading, spacing: 12)
                {
                    sectionTitle("メモ")
                    
                    TextEditor(text: Binding(
                        get: { profile?.memo ?? "" },
                        set: { newValue in
                            saveMemo(newValue)
                        }
                    ))
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 140)
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(.horizontal, 20)
        .overlay(alignment: .bottom)
        {
            if showingCopyToast
            {
                Text("コピーされました！")
                    .font(.footnote)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.75), in: Capsule())
                    .padding(.bottom, 24)
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.25)) {
                            showingCopyToast = false
                        }
                    }
                    .transition(
                        .opacity.combined(
                            with: .offset(CGSize(width: 0, height: 8))
                        )
                    )
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showingCopyToast)
        .sheet(isPresented: $isShowingProfileEdit)
        {
            ProfileEditView(profile: profile)
        }
    }

    private func menuRow(_ title: String) -> some View
    {
        HStack
        {
            Text(title)
                .font(.subheadline)
                .bold()

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(Color(.systemGray5))
    }

    private func sectionTitle(
        _ title: String,
        showsEdit: Bool = false
    ) -> some View
    {
        HStack
        {
            Text(title)
                .font(.headline)

            Spacer()

            if showsEdit
            {
                Button("編集")
                {
                    isShowingProfileEdit = true
                }
                .font(.headline)
            }
        }
    }

    private func infoRow(
        _ title: String,
        value: String,
        copyable: Bool = false
    ) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)

            Spacer()

            HStack(spacing: 8) {
                Text(value)
                    .font(.subheadline)
                    .lineLimit(1)

                if copyable
                {
                    Button {
                        //コピー対象がないときはコピーせず、トーストも出さない
                        guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                            return
                        }
                        
                        UIPasteboard.general.string = value

                        withAnimation(.easeIn(duration: 0.25)) {
                            showingCopyToast = true
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.easeOut(duration: 0.25)) {
                                showingCopyToast = false
                            }
                        }
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.subheadline)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("コピー")
                }
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 1)
        }
    }
    
    private func accountValue(for platform: String, isURL: Bool = false) -> String
    {
        guard let account = profile?.externalAccounts.first(
            where: { $0.platform == platform }
        ) else {
            return ""
        }

        return isURL ? account.profileURL : account.accountID
    }
            
    private func saveMemo(_ text: String)
    {
        if let profile {
            profile.memo = text
        } else if !text.isEmpty {
            let newProfile = UserProfile(memo: text)
            modelContext.insert(newProfile)
        }
    }

    private func measurementText(_ value: Double?, unit: String) -> String
    {
        guard let value else { return "" }
        return "\(value.formatted())\(unit)"
    }
}
