//
//  SwipeBackModifier.swift
//  Codive
//
//  Created on 2/16/26.
//

import SwiftUI
import UIKit

struct SwipeBackModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content.simultaneousGesture(
            DragGesture()
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = value.translation.height

                    if horizontal > 80 && abs(horizontal) > abs(vertical) {
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

extension View {
    func enableSwipeBack(action: @escaping () -> Void) -> some View {
        modifier(SwipeBackModifier(action: action))
    }
}
