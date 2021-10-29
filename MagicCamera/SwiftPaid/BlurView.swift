//
//  BlurView.swift
//  MagicCamera
//
//  Created by William on 2020/12/23.
//

import SwiftUI

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct BlurView: View {
    var body: some View {
        VisualEffectView(effect: UIBlurEffect(style: .light))
            .edgesIgnoringSafeArea(.all)
    }
}

struct BlurView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            loadImage(name: "icon.png")
            BlurView()
        }
    }
}
