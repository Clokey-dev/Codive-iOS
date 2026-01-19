//
//  UnderlineField.swift
//  Codive
//
//  Created by 한태빈 on 12/23/25.
//

import SwiftUI

struct UnderlineField<Trailing: View>: View {

    let title: String
    let requiredTag: String?
    @Binding var text: String

    let focus: FocusState<ProfileSettingView.Field?>.Binding
    let focusEquals: ProfileSettingView.Field
    let keyboardType: UIKeyboardType

    private let trailing: Trailing

    fileprivate var helperEmptyText: String?
    fileprivate var helperFilledText: String?
    fileprivate var helperErrorText: String?

    init(
        title: String,
        requiredTag: String?,
        text: Binding<String>,
        focus: FocusState<ProfileSettingView.Field?>.Binding,
        focusEquals: ProfileSettingView.Field,
        keyboardType: UIKeyboardType,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.requiredTag = requiredTag
        self._text = text
        self.focus = focus
        self.focusEquals = focusEquals
        self.keyboardType = keyboardType
        self.trailing = trailing()
        self.helperEmptyText = nil
        self.helperFilledText = nil
        self.helperErrorText = nil
    }

    init(
        title: String,
        requiredTag: String?,
        text: Binding<String>,
        focus: FocusState<ProfileSettingView.Field?>.Binding,
        focusEquals: ProfileSettingView.Field,
        keyboardType: UIKeyboardType
    ) where Trailing == EmptyView {
        self.init(
            title: title,
            requiredTag: requiredTag,
            text: text,
            focus: focus,
            focusEquals: focusEquals,
            keyboardType: keyboardType
        ) { EmptyView() }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            titleRow

            HStack(spacing: 10) {
                ZStack(alignment: .leading) {
                    // Placeholder 표시: 텍스트가 비어있고 포커스가 없을 때만 표시
                    if text.isEmpty,
                       focus.wrappedValue != focusEquals,
                       let helperEmptyText,
                       !helperEmptyText.isEmpty,
                       helperErrorText == nil {
                        Text(helperEmptyText)
                            .font(.codive_body3_medium)
                            .foregroundStyle(Color.Codive.grayscale4)
                    }

                    TextField("", text: $text)
                        .font(.codive_body2_medium)
                        .foregroundStyle(Color.Codive.grayscale1)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .focused(focus, equals: focusEquals)
                }

                trailing
            }
            .padding(.bottom, helperErrorText != nil && !(helperErrorText ?? "").isEmpty ? 5 : 0)

            Rectangle()
                .fill(Color.Codive.grayscale5)
                .frame(height: 1)

            helperRow
        }
    }

    private var titleRow: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.codive_body1_medium)
                .foregroundStyle(Color.Codive.grayscale1)

            if let requiredTag {
                Text(requiredTag)
                    .font(.codive_body3_medium)
                    .foregroundStyle(Color.Codive.point1)
            }

            Spacer(minLength: 0)
        }
    }

    private var helperRow: some View {
        let isError = !(helperErrorText ?? "").isEmpty
        
        let message: String? = {
            // 에러가 있으면 에러 메시지 표시
            if isError { return helperErrorText }
            if text.isEmpty { return nil }   // emptyText는 placeholder로만 표시
            return helperFilledText
        }()

        return Group {
            if let message, !message.isEmpty {
                Text(message)
                    .font(.codive_body2_medium)
                    .foregroundStyle(isError ? Color.Codive.point1 : Color.Codive.grayscale4)
                    .padding(.top, isError ? 5 : 2)
            } else {
                Color.clear.frame(height: 0)
            }
        }
    }
}

// MARK: - UnderlineField helper setter
extension UnderlineField {
    func setHelper(emptyText: String?, filledText: String?, errorText: String?) -> UnderlineField {
        var copy = self
        copy.helperEmptyText = emptyText
        copy.helperFilledText = filledText
        copy.helperErrorText = errorText
        return copy
    }
}
