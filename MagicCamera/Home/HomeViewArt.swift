//
//  HomeView3.swift
//  MagicCamera
//
//  Created by William on 2021/3/25.
//

import SwiftUI


struct NavigatingViewArt: View {
    private var title: String
    private var CmUtil: CoreMLUtils?
    private var canUse: Bool = true
    var body: some View {
        NavigationLink(destination: BeautyCameraView(CmUtil: self.CmUtil, fxName: title)) {
            ProImageAutoView(name: title + ".jpg", title:title)
        }
    }
    
    public init(title: String, CmUtil: CoreMLUtils? = nil) {
        self.title = title
        self.CmUtil = CmUtil
        self.canUse = DefaultsKeys.CanFxUse(name: title)
    }
}


struct HomeViewArt: View {
    @Environment(\.presentationMode) var presentationMode

    private var CmUtil: CoreMLUtils?
    public init(_ CmUtil: CoreMLUtils?) {
        self.CmUtil = CmUtil
    }

    var body: some View {
        HeaderStack(title: "ArtTab") {
            ScrollView {
                VStack {
                    Spacer()
                    VStack {
                        HStack{
                            Spacer()
                            NavigatingViewArt(title: "fleeting", CmUtil: self.CmUtil)
                            Spacer()
                            NavigatingViewArt(title: "hdr", CmUtil: self.CmUtil)
                            Spacer()
                        }
                        Spacer()
                        HStack{
                            Spacer()
                            NavigatingViewArt(title: "kuwahara", CmUtil: self.CmUtil)
                            Spacer()
                            NavigatingViewArt(title: "pixellate", CmUtil: self.CmUtil)
                            Spacer()
                        }
                        Spacer()
                        HStack{
                            Spacer()
                            NavigatingViewArt(title: "toon", CmUtil: self.CmUtil)
                            Spacer()
                            NavigatingViewArt(title: "lomo", CmUtil: self.CmUtil)
                            Spacer()
                        }
                    }
                    Spacer()
                    ForEach(Array(stride(from: 0, to: DefaultsKeys.allFilters.count, by: 2)), id: \.self) { idx in
                        HStack{
                            Spacer()
                            let filter = DefaultsKeys.getFilterAtIndex(idx)
                            let name = DefaultsKeys.allFilters[idx].name
                            NavigationLink(destination: BeautyCameraView(CmUtil: self.CmUtil, fxName: name, idx:idx)) {
                                ProImageView(name: "face.jpg", title:name, pro: true, filter: filter)
                            }
                            Spacer()
                            let filter = DefaultsKeys.getFilterAtIndex(idx+1)
                            let name = DefaultsKeys.allFilters[idx+1].name
                            NavigationLink(destination: BeautyCameraView(CmUtil: self.CmUtil, fxName: name, idx:idx+1)) {
                                ProImageView(name: "face.jpg", title:name, pro: true, filter: filter)
                            }
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

struct HomeViewArt_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            HomeViewArt(nil)
        }.onAppear() {
        }.environment(\.locale, .init(identifier: "zh"))
    }
}
