//
//  CameraCell.swift
//  Codive
//
//  Created by 황상환 on 10/13/25.
//

import SwiftUI

// MARK: - CameraCell
struct CameraCell: View {
    
    // MARK: - Properties
    let size: CGSize
    let onTap: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Color.gray.opacity(0.2)
                
                Image(systemName: "camera.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.Codive.grayscale3)
            }
            .frame(width: size.width, height: size.height)
        }
    }
}
