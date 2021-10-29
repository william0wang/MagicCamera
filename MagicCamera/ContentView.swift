//
//  ContentView.swift
//  TestApp
//
//  Created by William on 2020/12/11.
//

import AppTrackingTransparency
import AdSupport
import SwiftUI

struct ContentView: View, LanchFinishDelegate {
    mutating func doLanchFinish() {
        self.isLoading = false
    }
    
    @State private var isLoading = true
    func requestIDFA() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                // Tracking authorization completed. Start loading ads here.
                // loadAd()
            })
        } else {
            // Fallback on earlier versions
        }
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                LanchScreenView(finishDelegate: self).onAppear() {
                    requestIDFA()
                }
            } else {
                HomeView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
