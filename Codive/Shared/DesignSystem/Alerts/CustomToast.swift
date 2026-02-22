//
//  CustomToast.swift
//  Codive
//
//  Created on 2/17/26.
//

import SwiftUI

// MARK: - CustomToast
struct CustomToast: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(.white)

            Text(message)
                .font(.codive_body2_medium)
                .foregroundStyle(.white)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(Color.Codive.point1)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 20)
    }
}

// MARK: - Toast View Modifier
struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let duration: TimeInterval

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if isPresented {
                    CustomToast(message: message)
                        .padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    isPresented = false
                                }
                            }
                        }
                }
            }
            .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
}

extension View {
    func customToast(isPresented: Binding<Bool>, message: String, duration: TimeInterval = 3.0) -> some View {
        modifier(ToastModifier(isPresented: isPresented, message: message, duration: duration))
    }
}
