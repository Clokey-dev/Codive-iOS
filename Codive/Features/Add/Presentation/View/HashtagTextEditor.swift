//
//  HashtagTextEditor.swift
//  Codive
//
//  Created by 황상환 on 11/17/25.
//

import SwiftUI
import UIKit

struct HashtagTextEditor: UIViewRepresentable {
    
    // MARK: - Properties
    @Binding var text: String
    var hashtagColor: UIColor
    var font: UIFont
    var textColor: UIColor
    var placeholder: String = ""
    var placeholderColor: UIColor = .lightGray
    
    // MARK: - UIViewRepresentable
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = font
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        textView.isScrollEnabled = true
        
        if text.isEmpty && !placeholder.isEmpty {
            textView.text = placeholder
            textView.textColor = placeholderColor
        } else {
            textView.attributedText = highlight(text: text)
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if context.coordinator.isShowingPlaceholder {
            if uiView.text != placeholder {
                uiView.text = placeholder
                uiView.textColor = placeholderColor
            }
        } else {
            if uiView.text != text {
                let selectedRange = uiView.selectedRange
                uiView.attributedText = highlight(text: text)
                uiView.selectedRange = selectedRange
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Private Methods
    private func highlight(text: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: text)
        attributed.addAttribute(.font, value: font, range: NSRange(location: 0, length: text.count))
        attributed.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: text.count))
        
        let pattern = "(?<!#)#(?!#)[ㄱ-ㅎㅏ-ㅣ가-힣a-zA-Z0-9]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return attributed }
        
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: text.count))
        for match in matches {
            attributed.addAttribute(.foregroundColor, value: hashtagColor, range: match.range)
        }
        
        return attributed
    }
}

// MARK: - Coordinator
extension HashtagTextEditor {
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        // MARK: - Properties
        var parent: HashtagTextEditor
        var isShowingPlaceholder: Bool
        
        // MARK: - Initializer
        init(_ parent: HashtagTextEditor) {
            self.parent = parent
            self.isShowingPlaceholder = parent.text.isEmpty && !parent.placeholder.isEmpty
        }
        
        // MARK: - UITextViewDelegate
        func textViewDidBeginEditing(_ textView: UITextView) {
            if isShowingPlaceholder {
                textView.text = ""
                textView.textColor = parent.textColor
                isShowingPlaceholder = false
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = parent.placeholderColor
                isShowingPlaceholder = true
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if isShowingPlaceholder {
                return
            }
            
            let selectedRange = textView.selectedRange
            parent.text = textView.text
            textView.attributedText = parent.highlight(text: textView.text)
            textView.selectedRange = selectedRange
        }
    }
}
