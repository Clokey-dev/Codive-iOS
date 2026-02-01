//
//  UIApplication+Keyboard.swift
//  Codive
//
//  Created by 황상환 on 2025/01/28.
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
