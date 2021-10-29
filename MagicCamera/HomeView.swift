//
//  HomeView.swift
//  MagicCamera
//
//  Created by William on 2020/12/17.
//

import SwiftUI

struct HomeView: View {
    private var CmUtil: CoreMLUtils?
    @State private var notPaid : Bool
    @State private var showingActionSheet = false

    public init() {
        self._notPaid = State(initialValue: !DefaultsKeys.IsPaid)
        self.CmUtil = CoreMLUtils()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                loadImage(name:"gb.jpg").resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        loadImage(name:"logo_zw.png").resizable()
                            .frame(width:29, height:25)
                        Spacer()
                        loadImage(name:"vip.png").resizable()
                            .frame(width:40, height:40)
                    }.padding(.leading, 15)
                    .padding(.bottom, 10)
                    .padding(.trailing, 30)
                    NavigationLink(destination: HomeViewStyle(self.CmUtil)) {
                        ZStack {
                            loadImage(name:"frame.jpg").resizable()
                            .scaledToFill().frame(width:227, height:227)
                            VideoView().frame(width:210, height:210)
                        }
                    }
                    .padding(.bottom, 10)
                    HStack {
                        NavigationLink(destination: HomeViewStyle(self.CmUtil)) {
                            ZStack {
                                loadImage(name:"cam_style.jpg").resizable()
                                .scaledToFill().frame(width:147, height:146)
                                .cornerRadius(5)
                                Text("StyleTab")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .padding(.bottom, 100)
                                    .padding(.trailing, 60)
                            }
                            
                        }
                        .padding(.trailing, 3)
                        VStack {
                            NavigationLink(destination: HomeViewCartoon(self.CmUtil)) {
                                ZStack {
                                    loadImage(name:"cam_cartoon.png").resizable()
                                        .scaledToFill().frame(width:139, height:68)
                                    Text("CartoonTab")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                        .padding(.bottom, 30)
                                        .padding(.trailing, 60)
                                }
                            }
                            .padding(.bottom, 3)
                            NavigationLink(destination: HomeViewArt(self.CmUtil)) {
                                ZStack {
                                    loadImage(name:"cam_art.png").resizable()
                                    .scaledToFill().frame(width:139, height:68)
                                    Text("ArtTab")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                        .padding(.bottom, 30)
                                        .padding(.trailing, 60)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    ZStack {
                        loadImage(name:"info.png").resizable()
                            .scaledToFill().frame(width:241, height:76)
                        Text("CanGet2")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex:"#825A5A") ?? .black)
                    }
                    .padding(.bottom, 5)
                    NavigationLink(destination: BeautyCameraView(CmUtil: self.CmUtil)) {
                        loadImage(name:"take_photo.png").resizable()
                            .scaledToFill().frame(width:58, height:58)
                    }
                }
            }
            .navigationBarTitle("AppName")
            .navigationBarHidden(true)
        }.navigationViewStyle(StackNavigationViewStyle())
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            HomeView()
        }.onAppear() {
        }.environment(\.locale, .init(identifier: "zh"))
    }
}
