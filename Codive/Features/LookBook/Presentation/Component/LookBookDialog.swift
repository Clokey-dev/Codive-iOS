//
//  LookBookDialog.swift
//  Codive
//
//  Created by 한금준 on 11/25/25.
//

import SwiftUI

struct LookBookDialog: View {
    let title: String
    let hintText: String
    let buttonText: String
    let action: (String) -> Void
    
    @State private var inputText: String = ""
    
    let dismissAction: (() -> Void)?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text(title)
                        .font(Font.codive_title2)
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.top, 30)
                
                VStack(alignment: .center, spacing: 5) {
                    TextField(hintText, text: Binding(
                        get: { inputText },
                        set: { inputText = String($0.prefix(10)) }
                    ))
                        .multilineTextAlignment(.center)
                        .font(Font.codive_body2_medium)
                        .foregroundStyle(.black)
                        .frame(height: 36)
                        .overlay(
                            VStack {
                                Spacer()
                                Divider()
                                    .background(Color.gray)
                            }
                        )
                        .padding(.horizontal, 32)
                }
                .padding(.top, 16)
                
                CustomButton(text: buttonText, widthType: .fixed) {
                    action(inputText)
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
                .padding(.bottom, 24)
            }
            .frame(width: 311, height: 202)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
            
            Button(
                action: {
                    dismissAction?()
                },
                label: {
                    Image("cancel")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .scaledToFit()
                }
            )
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
        .frame(width: 311, height: 202)
    }
}
