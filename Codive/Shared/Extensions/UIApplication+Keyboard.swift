//
//  UIApplication+Keyboard.swift
//  Codive
//
//  Created by Claude on 2025/01/28.
//

import UIKit

extension UIApplication {
    func hideKeyboard() {
        self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first?
            .rootViewController?
            .view.endEditing(true)
    }
}
