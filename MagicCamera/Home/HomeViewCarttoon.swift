//
//  HomeView1.swift
//  MagicCamera
//
//  Created by William on 2021/3/25.
//

import SwiftUI

struct NavigatingViewCartoon: View {
    private var name: String
    private var title: String
    private var CmUtil: CoreMLUtils?
    var body: some View {
        NavigationLink(destination: LiveCameraView(CmUtil: self.CmUtil, fxName: title)) {
            ProImageView(name: name, title:title)
        }
    }
    
    public init(title: String, CmUtil: CoreMLUtils? = nil, imageName: String = "") {
        self.title = title
        self.CmUtil = CmUtil
        if imageName.isEmpty {
            self.name = title+".jpg"
        } else {
            self.name = imageName
        }
    }
}

struct HomeViewCartoon: View {
    @Environment(\.presentationMode) var presentationMode
    private var CmUtil: CoreMLUtils?
    public init(_ CmUtil: CoreMLUtils?) {
        self.CmUtil = CmUtil
    }
    
    var body: some View {
        HeaderStack(title: "CartoonTab") {
            ScrollView {
                VStack {
                    VStack {
                        Spacer()
                        HStack{
                            Spacer()
                            NavigatingViewCartoon(title:  "photo2cartoon_bubble", CmUtil: self.CmUtil)
                            Spacer()
                            NavigatingViewCartoon(title:  "photo2cartoon_flower", CmUtil: self.CmUtil)
                            Spacer()
                        }
                        Spacer()
                        HStack{
                            Spacer()
                            NavigatingViewCartoon(title:  "photo2cartoon_romance", CmUtil: self.CmUtil)
                            Spacer()
                            NavigatingViewCartoon(title:  "photo2cartoon_colorful", CmUtil: self.CmUtil)
                            Spacer()
                        }
                    }
                    Spacer()
                    HStack{
                        Spacer()
                        NavigatingViewCartoon(title:  "photo2cartoon", CmUtil: self.CmUtil, imageName: "IMG_0075.JPG")
                        Spacer()
                        NavigatingViewCartoon(title:  "hayao", CmUtil: self.CmUtil, imageName: "IMG_0008.JPG")
                        Spacer()
                    }
                    Spacer()
                    HStack{
                        Spacer()
                        NavigatingViewCartoon(title:  "chayao8", CmUtil: self.CmUtil, imageName: "IMG_0010.JPG")
                        Spacer()
                        NavigatingViewCartoon(title:  "cpaprika8", CmUtil: self.CmUtil, imageName: "IMG_0011.JPG")
                        Spacer()
                    }
                    Spacer()
                    HStack{
                        Spacer()
                        NavigatingViewCartoon(title:  "paprika", CmUtil: self.CmUtil, imageName: "IMG_0009.JPG")
                        Spacer()
                        NavigatingViewCartoon(title:  "chosoda8", CmUtil: self.CmUtil, imageName: "IMG_0012.JPG")
                        Spacer()
                    }
                    VStack {
                        HStack{
                            Spacer()
                            NavigatingViewCartoon(title:  "style_rain_princess", CmUtil: self.CmUtil)
                            Spacer()
                            NavigatingViewCartoon(title:  "warpgan8", CmUtil: self.CmUtil, imageName: "IMG_0013.JPG")
                            Spacer()
                        }
                        Spacer()
                        HStack{
                            Spacer()
                            NavigatingViewCartoon(title:  "style_pointillism8", CmUtil: self.CmUtil)
                            Spacer()
                            NavigatingViewCartoon(title:  "style_wave", CmUtil: self.CmUtil)
                            Spacer()
                        }
                        Spacer()
                        HStack{
                            Spacer()
                            NavigatingViewCartoon(title:  "style_starry_night8", CmUtil: self.CmUtil)
                            Spacer()
                            NavigatingViewCartoon(title:  "style_la_muse", CmUtil: self.CmUtil)
                            Spacer()
                        }
                        Spacer()
                        HStack{
                            Spacer()
                            NavigatingViewCartoon(title:  "style_shipwreck_minotaur", CmUtil: self.CmUtil)
                            Spacer()
                            NavigatingViewCartoon(title:  "style_the_scream", CmUtil: self.CmUtil)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

struct HomeViewCartoon_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            HomeViewCartoon(nil)
        }.onAppear() {
        }.environment(\.locale, .init(identifier: "zh"))
    }
}
