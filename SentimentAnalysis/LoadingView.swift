//
//  LoadingView.swift
//  SentimentAnalysis
//
//  Created by 間口秀人 on 2023/01/08.
//

import SwiftUI

class AppControl: ObservableObject {
    
    static let shared = AppControl()
    
    @Published var zIndex: Double = 0.0
    
    func showLoading() {
        zIndex = 1.0
    }
    
    func hideLoading() {
        zIndex = 0.0
    }
}

struct LoadingView: View {
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .opacity(0.6)
            ProgressView("")
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
