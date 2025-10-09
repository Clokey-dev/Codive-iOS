//
//  CustomTagView.swift
//  Codive
//
//  Created by 황상환 on 10/5/25.
//

import SwiftUI

enum CustomTagType {
    case basic(title: String, content: String)
    case closable(title: String, content: String, onClose: () -> Void)
    case navigable(title: String, content: String, onTap: () -> Void)
}

struct CustomTagView: View {
    let type: CustomTagType
    
    var body: some View {
        switch type {
        case .basic(let title, let content):
            BasicTagView(title: title, content: content)
            
        case .closable(let title, let content, let onClose):
            ClosableTagView(title: title, content: content, onClose: onClose)
            
        case .navigable(let title, let content, let onTap):
            NavigableTagView(title: title, content: content, onTap: onTap)
        }
    }
}

// MARK: - Basic Tag (타이틀 + 내용)
private struct BasicTagView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.codive_body3_medium)
                .foregroundStyle(Color.Codive.main3)
            
            Text(content)
                .font(.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale1)
                .lineLimit(2)
        }
        .frame(width: 120, height: 70, alignment: .leading)
        .padding(.horizontal, 8)
        .background(Color.Codive.main6.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Closable Tag (타이틀 + X버튼 + 내용)
private struct ClosableTagView: View {
    let title: String
    let content: String
    let onClose: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.codive_body3_medium)
                    .foregroundStyle(Color.Codive.main3)
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.Codive.main0)
                }
            }
            
            Text(content)
                .font(.codive_body2_medium)
                .foregroundStyle(Color.Codive.grayscale1)
                .lineLimit(2)
        }
        .frame(width: 120, height: 70, alignment: .leading)
        .padding(.horizontal, 8)
        .background(Color.Codive.main6.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Navigable Tag (타이틀 + 내용 + > 버튼)
private struct NavigableTagView: View {
    let title: String
    let content: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.codive_body3_medium)
                        .foregroundStyle(Color.Codive.main3)
                    
                    Text(content)
                        .font(.codive_body2_medium)
                        .foregroundStyle(Color.Codive.grayscale1)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.Codive.main0)
            }
            .frame(width: 156, height: 70, alignment: .leading)
            .padding(.horizontal, 8)
            .background(Color.Codive.main6.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct CustomTagView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Basic Tag
            CustomTagView(type: .basic(
                title: "brand",
                content: "texttexttexttexttexttext..."
            ))
            
            // Closable Tag
            CustomTagView(type: .closable(
                title: "Typeservice",
                content: "Layered Henry Neck Long Slee..."
            ) {
                print("Close tapped")
            })

            // Navigable Tag
            CustomTagView(type: .navigable(
                title: "Typeservice",
                content: "Layered Henry Neck Long Slee..."
            ) {
                print("Navigate tapped")
            })
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
