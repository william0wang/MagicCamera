//
//  ImageView.swift
//  MagicCamera
//
//  Created by William on 2020/12/15.
//


import UIKit
import SwiftUI
import Lottie

struct ArtImageView: View {
    @Binding var image: UIImage
    @Binding var working: Bool
    @Binding var showNow: Bool
    @State private var showAd = true
    @State private var subscribe = false
    @State private var fullscreenAd = false
    @State private var fullscreenAdFinishOk = false
    @State private var selectedName : String
    @State var savePopup = false
    @State var savePopupOk = false
    @State var saveError : Error?
    public var delegateFx: CameraFxImage?
    let animaView = AnimationView()
    let width = UIScreen.main.bounds.width-10
    
    private func savePhoto() {
        let imageSaver = ImageSaver(action: { ok, error in
            self.savePopupOk = ok
            self.saveError = error
            self.savePopup = true
        })
        imageSaver.writeToPhotoAlbum(image: image)
    }
    
    public init(name: String, image: Binding<UIImage>, working: Binding<Bool>, showNow: Binding<Bool>, delegateFx: CameraFxImage?) {
        self._selectedName = State(initialValue: name)
        self._image = image
        self._working = working
        self._showNow = showNow
        self.delegateFx = delegateFx
    }
    
    private mutating func doWork(_ name: String) {
        if selectedName == name {
            return
        }
        self.delegateFx?.doFx(name)
        self.selectedName = name
        self.showNow = true
        self.showAd = true
        self.subscribe = false
        self.fullscreenAd = false
        self.fullscreenAdFinishOk = false
    }
    
    var body: some View {
        var weakSelf = self
        GeometryReader { geometry in
            HeaderStack(title: "ArtTab") {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width, height: width)
                        .padding(10)
                    if working {
                        ScanningView()
                            .frame(width: width+10, height: width+10)
                    }
                }.popup(isPresented: $savePopup, autohideIn: 3) {
                    ImageSaveView(savePopupOk: self.$savePopupOk, saveError: self.$saveError)
                }
                HStack {
                    Button(action: {
                        weakSelf.savePhoto()
                    }, label: {
                        Text("SaveFile")
                    })
                    .disabled(working)
                }
                Spacer()
                ScrollView(.horizontal) { proxy in
                    HStack {
                        Button(action: {
                            weakSelf.doWork("style_pointillism8")
                        }, label: {
                            ProSelectView(name: "style_pointillism8.jpg", title:"style_pointillism8",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .scrollId("style_pointillism8")
                        .disabled(working)
                        
                        Button(action: {
                            weakSelf.doWork("style_starry_night8")
                        }, label: {
                            ProSelectView(name: "style_starry_night8.jpg", title:"style_starry_night8",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .scrollId("style_starry_night8")
                        .disabled(working)
                        
                        Button(action: {
                            weakSelf.doWork("style_la_muse")
                        }, label: {
                            ProSelectView(name: "style_la_muse.jpg", title:"style_la_muse",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .scrollId("style_la_muse")
                        .disabled(working)

                        Button(action: {
                            weakSelf.doWork("style_rain_princess")
                        }, label: {
                            ProSelectView(name: "style_rain_princess.jpg", title:"style_rain_princess",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .scrollId("style_rain_princess")
                        .disabled(working)

                        Button(action: {
                            weakSelf.doWork("style_udnie")
                        }, label: {
                            ProSelectView(name: "style_udnie.jpg", title:"style_udnie",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .scrollId("style_udnie")
                        .disabled(working)

                        Button(action: {
                            weakSelf.doWork("style_wave")
                        }, label: {
                            ProSelectView(name: "style_wave.jpg", title:"style_wave",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .scrollId("style_wave")
                        .disabled(working)
                        
                        Button(action: {
                            weakSelf.doWork("style_shipwreck_minotaur")
                        }, label: {
                            ProSelectView(name: "style_shipwreck_minotaur.jpg", title:"style_shipwreck_minotaur",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .scrollId("style_shipwreck_minotaur")
                        .disabled(working)
                        
                        Button(action: {
                            weakSelf.doWork("style_the_scream")
                        }, label: {
                            ProSelectView(name: "style_the_scream.jpg", title:"style_the_scream",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .scrollId("style_the_scream")
                        .disabled(working)
                    }
                    .disabled(working)
                    .onAppear {
                        DispatchQueue.init(label: "scroll").async{
                            usleep(1000*5)
                            DispatchQueue.main.async {
                                proxy.scrollTo(self.selectedName)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ArtImageView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ArtImageView(name: "style_pointillism8",
                image: .constant(UIImage()),
                working: .constant(false),
                showNow: .constant(true),
                delegateFx: nil)
        }.onAppear() {
        }
    }
}
