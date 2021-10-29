//
//  ImageView.swift
//  MagicCamera
//
//  Created by William on 2020/12/15.
//


import UIKit
import SwiftUI
import Lottie

struct StyleImageView: View {
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
            HeaderStack(title: "StyleTab") {
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
                            weakSelf.doWork("aged")
                        }, label: {
                            ProSelectView(name: "aged.jpg", title:"aged",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .scrollId("aged")
                        .disabled(working)
                        
                        Button(action: {
                            weakSelf.doWork("attgan_old")
                        }, label: {
                            ProSelectView(name: "attgan_old.jpg", title:"attgan_old",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .scrollId("attgan_old")
                        .disabled(working)
                        
                        Button(action: {
                            weakSelf.doWork("attgan_young")
                        }, label: {
                            ProSelectView(name: "attgan_young.jpg", title:"attgan_young",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .scrollId("attgan_young")
                        .disabled(working)
                        
                        Button(action: {
                            weakSelf.doWork("attgan_blond_hair")
                        }, label: {
                            ProSelectView(name: "attgan_blond_hair.jpg", title:"attgan_blond_hair",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .scrollId("attgan_blond_hair")
                        .disabled(working)
                        
                        Button(action: {
                            weakSelf.doWork("attgan_brown_hair")
                        }, label: {
                            ProSelectView(name: "attgan_brown_hair.jpg", title:"attgan_brown_hair",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .scrollId("attgan_brown_hair")
                        .disabled(working)
                        
                        Button(action: {
                            weakSelf.doWork("attgan_mustache")
                        }, label: {
                            ProSelectView(name: "attgan_mustache.jpg", title:"attgan_mustache",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .scrollId("attgan_mustache")
                        .disabled(working)
                        
                        Button(action: {
                            weakSelf.doWork("attgan_male")
                        }, label: {
                            ProSelectView(name: "attgan_male.jpg", title:"attgan_male",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .scrollId("attgan_male")
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

struct StyleImageView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            StyleImageView(name: "aged",
                image: .constant(UIImage()),
                working: .constant(false),
                showNow: .constant(true),
                delegateFx: nil)
        }.onAppear() {
        }
    }
}
