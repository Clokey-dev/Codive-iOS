import SwiftUI

extension View {
    func codiveCardShadow() -> some View {
        shadow(color: Color(hex: "#636363").opacity(0.06), radius: 8, x: 0, y: 2)
    }
}
