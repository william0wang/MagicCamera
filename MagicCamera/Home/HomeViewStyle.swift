//
//  HomeView2.swift
//  MagicCamera
//
//  Created by William on 2021/3/25.
//

import SwiftUI

struct HomeViewStyle: View {
    @Environment(\.presentationMode) var presentationMode
    private var CmUtil: CoreMLUtils?
    public init(_ CmUtil: CoreMLUtils?) {
        self.CmUtil = CmUtil
    }

    var body: some View {
        HeaderStack(title: "StyleTab") {
            ScrollView {
                VStack {
                    Spacer()
                    HStack{
                        Spacer()
                        NavigationLink(destination: BeautyCameraView(CmUtil: self.CmUtil)) {
                            ProImageView(name: "beauty.jpg", title:"BeautyCam", pro:false)
                        }
                        Spacer()
                        NavigationLink(destination: LiveCameraView(CmUtil: self.CmUtil, fxName: "photo2cartoon")) {
                            ProImageView(name: "IMG_0074.JPG", title:"photo2cartoon")
                        }
                        Spacer()
                    }
                    Spacer()
                    HStack{
                        Spacer()
                        NavigationLink(destination: StyleCameraView(CmUtil: self.CmUtil, fxName: "aged")) {
                            ProImageView(name: "aged.jpg", title:"aged")
                        }
                        Spacer()
                        NavigationLink(destination: StyleCameraView(CmUtil: self.CmUtil, fxName: "attgan_old")) {
                            ProImageView(name: "attgan_old.jpg", title:"attgan_old")
                        }
                        Spacer()
                    }
                    Spacer()
                    HStack{
                        Spacer()
                        NavigationLink(destination: StyleCameraView(CmUtil: self.CmUtil, fxName: "attgan_blond_hair")) {
                            ProImageView(name: "attgan_blond_hair.jpg", title:"attgan_blond_hair")
                        }
                        Spacer()
                        NavigationLink(destination: StyleCameraView(CmUtil: self.CmUtil, fxName: "attgan_young")) {
                            ProImageView(name: "attgan_young.jpg", title:"attgan_young")
                        }
                        Spacer()
                    }
                    Spacer()
                    HStack{
                        Spacer()
                        NavigationLink(destination: StyleCameraView(CmUtil: self.CmUtil, fxName: "attgan_mustache")) {
                            ProImageView(name: "attgan_mustache.jpg", title:"attgan_mustache")
                        }
                        Spacer()
                        NavigationLink(destination: StyleCameraView(CmUtil: self.CmUtil, fxName: "attgan_male")) {
                            ProImageView(name: "attgan_male.jpg", title:"attgan_male")
                        }
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
        }
    }
}


struct HomeViewStyle_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            HomeViewStyle(nil)
        }.onAppear() {
        }.environment(\.locale, .init(identifier: "zh"))
    }
}
