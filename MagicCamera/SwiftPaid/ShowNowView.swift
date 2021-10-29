//
//  ShowNowView.swift
//  MagicCamera
//
//  Created by William on 2020/12/23.
//

import SwiftUI
import UIKit
import Lottie

struct OkView : UIViewRepresentable {
    typealias UIViewType = AnimationView
    
    
    func makeUIView(context: Context) -> AnimationView {
        let animaView = AnimationView()
        let anima = Lottie.Animation.named("33886-check-okey-done")
        
        animaView.animation = anima
        
        animaView.loopMode = .playOnce
        animaView.animationSpeed = 1
        
        animaView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        animaView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        animaView.play()
        return animaView
    }
    
    func updateUIView(_ uiView: AnimationView, context: Context) {
        
    }
}

struct ShowNowView: View {
    @Binding var show: Bool
    @Binding var subscribe: Bool
    
    @State var loading = true
    var body: some View {
        let weakself = self
        ZStack {
            BlurView().edgesIgnoringSafeArea(.all)
            RoundedRectangle(cornerRadius: 50)
                .foregroundColor(Color(hex:"#f8f8f8") ?? .white)
                .frame(width: 260, height: 260)
                .overlay(
                        Button(action: {
                            self.show = false
                        }, label: {
                            Text("X")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex:"#808080") ?? .black)
                        }).offset(x: -100, y: -100)
                )
            VStack {
                ZStack {
                    if !loading {
                        loadImage(name:"IMG_0010.JPG")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .transition(.opacity)
                    } else {
                        loadImage(name:"face.jpg")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .transition(.opacity)
                    }
                }.overlay(OkView()
                            .frame(width: 50, height: 50)
                            .offset(x: 40, y: 40))
                Text("CartoonOk")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                Button(action: {
                    self.show = false
                    self.subscribe = true
                }, label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 50)
                            .foregroundColor(.black)
                            .frame(width: 180, height: 40)
                        Text("ShowNow")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                })
            }
        }.onAppear() {
            withAnimation(.easeInOut(duration:2)) {
                weakself.loading.toggle()
            }
        }
    }
}

struct ShowNowView_Previews: PreviewProvider {
    static var previews: some View {
        ShowNowView(show: .constant(false), subscribe: .constant(false))
    }
}
