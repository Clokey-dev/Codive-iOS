//
//  LoadingView.swift
//  Codive
//
//  Created by 황상환 on 11/3/25.
//

import SwiftUI

struct LoadingView: View {
    
    var body: some View {
        ZStack {
            Color.white
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.Codive.main0))
                .scaleEffect(1.5)
        }
        .ignoresSafeArea()
    }
}
