import SwiftUI

@main
struct ClokeyApp: App {
    var body: some Scene {
        WindowGroup {
            Text(
                "Title 1 (Semibold 20)"
            )
            .font(
                .clokey_title1
            )
            
            Text(
                "Body 1 (Medium 16)"
            )
            .font(
                .clokey_body1_medium
            )
            
            Text(
                "Body 2 (Regular 14)"
            )
            .font(
                .clokey_body2_regular
            )
        }
    }
}
