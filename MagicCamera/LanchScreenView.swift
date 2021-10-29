//
//  LanchScreenView.swift
//  MagicCamera
//
//  Created by William on 2020/12/17.
//

import SwiftUI
import UIKit
import Lottie

public protocol LanchFinishDelegate {
    mutating func doLanchFinish()
}

struct LanchView : UIViewRepresentable {
    typealias UIViewType = AnimationView
    
    
    func makeUIView(context: Context) -> AnimationView {
        let animaView = AnimationView()
        let anima = Lottie.Animation.named("15457-camera-snapshot")
        
        animaView.animation = anima
        
        animaView.loopMode = .loop
        animaView.animationSpeed = 6
        
        animaView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        animaView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        animaView.play()
        return animaView
    }
    
    func updateUIView(_ uiView: AnimationView, context: Context) {
        
    }
}

struct LanchScreenView: View {
    @State private var isLoading = true
    var finishDelegate: LanchFinishDelegate?
    
    var body: some View {
        VStack {
            var weakself = self
            Spacer()
            HStack {
                Spacer()
                LanchView()
                    .frame(width: 200, height: 200)
                    .onAppear {
                       DispatchQueue.init(label: "lanch").async{
                            let second = Date().timeIntervalSince1970
                            DefaultsKeys.InitFilters()
                            let second2 = Date().timeIntervalSince1970
                            let t = Int32((0.95 + second - second2)*1000)*1000
                            if t > 0 {
                                usleep(useconds_t(t))
                            }
                            weakself.finishDelegate?.doLanchFinish()
                       }
                    }
                Spacer()
            }
            Spacer()
        }.background(loadImage(name:"gb.jpg").resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all))
    }
    
    init(finishDelegate: LanchFinishDelegate?) {
        self.finishDelegate = finishDelegate
    }
}

struct LanchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LanchScreenView(finishDelegate:nil)
    }
}
