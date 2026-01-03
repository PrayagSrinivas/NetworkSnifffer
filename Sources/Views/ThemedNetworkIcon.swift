import SwiftUI

public struct ThemedNetworkIcon: View {
    @Environment(\.colorScheme) private var colorScheme

    private let size: CGFloat
    private let iconSize: CGFloat
    private let hasBackground: Bool

    public init(size: CGFloat = 50, iconSize: CGFloat = 24, hasBackground: Bool = true) {
        self.size = size
        self.iconSize = iconSize
        self.hasBackground = hasBackground
    }

    public var body: some View {
        let isDark = colorScheme == .dark
        ZStack {
            if hasBackground {
                Circle()
                    .fill(isDark ? Color.white : Color.black)
                    .frame(width: size, height: size)
            }
            Image(systemName: "network")
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundColor(isDark ? .black : .white)
        }
        .accessibilityLabel(Text("Network"))
    }
}
