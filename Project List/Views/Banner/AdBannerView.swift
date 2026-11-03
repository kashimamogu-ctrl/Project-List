import SwiftUI

// 今はダミー表示。後でGoogle AdMobのViewに差し替える
struct AdBannerView: View
{
    init()
    {
        // 画面上のタイトルを、丸いフォント・本文の色にする
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .font: UIFont.rounded(size: 17, weight: .semibold),
            .foregroundColor: UIColor(AppTheme.text)
        ]
        appearance.largeTitleTextAttributes = [
            .font: UIFont.rounded(size: 28, weight: .bold),
            .foregroundColor: UIColor(AppTheme.text)
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View
    {
        HStack
        {
            Spacer()
            Text("広告エリア")
                .font(.caption2)
                .foregroundColor(AppTheme.subText)
            Spacer()
        }
        .frame(height: 50)
        .background(AppTheme.background)
        .overlay(alignment: .top) { AppDivider() }
    }
}

extension UIFont
{
    // 丸みのあるシステムフォント（SF Pro Rounded）
    static func rounded(size: CGFloat, weight: UIFont.Weight) -> UIFont
    {
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = font.fontDescriptor.withDesign(.rounded) else { return font }
        return UIFont(descriptor: descriptor, size: size)
    }
}
