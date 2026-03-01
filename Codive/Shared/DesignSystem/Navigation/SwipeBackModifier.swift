//
//  SwipeBackModifier.swift
//  Codive
//
//  Created on 2/16/26.
//

import SwiftUI
import UIKit

//struct SwipeBackModifier: ViewModifier {
//    func body(content: Content) -> some View {
//        content.background(SwipeBackHelper())
//    }
//}

struct SwipeBackModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content.highPriorityGesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 80 &&
                       abs(value.translation.height) < 50 {
                        action()
                    }
                }
        )
    }
}

struct SwipeBackHelper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let nav = uiViewController.navigationController else { return }
        nav.interactivePopGestureRecognizer?.isEnabled = true
        nav.interactivePopGestureRecognizer?.delegate = context.coordinator
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }
}

//extension View {
//    func enableSwipeBack() -> some View {
//        modifier(SwipeBackModifier())
//    }
//}
extension View {
    func enableSwipeBack(action: @escaping () -> Void) -> some View {
        modifier(SwipeBackModifier(action: action))
    }
}
