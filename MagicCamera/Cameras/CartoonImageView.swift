//
//  ImageView.swift
//  MagicCamera
//
//  Created by William on 2020/12/15.
//


import UIKit
import SwiftUI
import Lottie

struct ScanningView : UIViewRepresentable {
    typealias UIViewType = AnimationView
    
    func makeUIView(context: Context) -> AnimationView {
        let animaView = AnimationView()
        let anima = Lottie.Animation.named("8657-camera-scanning-effect")
        
        animaView.animation = anima
        
        animaView.loopMode = .loop
        
        animaView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        animaView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        animaView.play()
        return animaView
    }
    
    func updateUIView(_ uiView: AnimationView, context: Context) {
        
    }
}

struct ImageView: View {
    @Binding var image: UIImage
    @Binding var cartoon: UIImage
    @Binding var glass: UIImage
    @Binding var working: Bool
    @Binding var showNow: Bool
    @Binding var glassFace: Bool
    @Binding var thinFace: Bool
    @State private var showAd = true
    @State private var subscribe = false
    @State private var fullscreenAd = false
    @State private var fullscreenAdFinishOk = false
    @State private var selectedName : String
    @State var savePopup = false
    @State var savePopupOk = false
    @State var saveError : Error?
    private var lastGlass = false
    private var lastThin = false
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
    
    public init(name: String, image: Binding<UIImage>, working: Binding<Bool>, showNow: Binding<Bool>, cartoon: Binding<UIImage>, glass: Binding<UIImage>, glassFace: Binding<Bool>, thinFace: Binding<Bool>, delegateFx: CameraFxImage?) {
        self._selectedName = State(initialValue: name)
        self._image = image
        self._cartoon = cartoon
        self._glass = glass
        self._glassFace = glassFace
        self._thinFace = thinFace
        self._working = working
        self._showNow = showNow
        self.delegateFx = delegateFx
        self.lastGlass = self.glassFace
        self.lastThin = self.thinFace
    }
    
    private mutating func doWork(_ name: String) {
        if selectedName == name {
            if lastGlass == glassFace && lastThin == thinFace{
                return
            }
            if lastGlass != glassFace {
                lastGlass = glassFace
                if lastGlass {
                    self.image = self.glass
                } else {
                    self.image = self.cartoon
                }
                return
            }
            lastThin = thinFace
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
            HeaderStack(title: "CartoonTab") {
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
                    Spacer()
                    Button(action: {
                        weakSelf.savePhoto()
                    }, label: {
                        Text("SaveFile")
                    })
                    .disabled(working)
                    Spacer()
                    Toggle("thin", isOn:$thinFace)
                        .onReceive([self.thinFace].publisher.first()) { (value) in
                            weakSelf.doWork(selectedName)
                        }
                        .toggleStyle(CheckboxStyle())
                        .frame(width: 70, height: 30)
                        .padding(.trailing, 10)
                        .disabled(working)
                    Spacer()
                    Toggle("glass", isOn:$glassFace)
                        .onReceive([self.glassFace].publisher.first()) { (value) in
                            weakSelf.doWork(selectedName)
                        }
                        .toggleStyle(CheckboxStyle())
                        .frame(width: 70, height: 30)
                        .padding(.trailing, 10)
                        .disabled(working)
                    Spacer()
                }
                Spacer()
                ScrollView(.horizontal) { proxy in
                    HStack {
                        Button(action: {
                            weakSelf.doWork("photo2cartoon")
                        }, label: {
                            ProSelectView(name: "IMG_0075.JPG", title:"photo2cartoon",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .disabled(working)
                        .scrollId("photo2cartoon")
                        
                        Button(action: {
                            weakSelf.doWork("photo2cartoon_flower")
                        }, label: {
                            ProSelectView(name: "photo2cartoon_flower.jpg", title:"photo2cartoon_flower",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .disabled(working)
                        .scrollId("photo2cartoon_flower")
                        
                        Button(action: {
                            weakSelf.doWork("photo2cartoon_bubble")
                        }, label: {
                            ProSelectView(name: "photo2cartoon_bubble.jpg", title:"photo2cartoon_bubble",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .disabled(working)
                        .scrollId("photo2cartoon_bubble")
                        
                        Button(action: {
                            weakSelf.doWork("photo2cartoon_romance")
                        }, label: {
                            ProSelectView(name: "photo2cartoon_romance.jpg", title:"photo2cartoon_romance",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .disabled(working)
                        .scrollId("photo2cartoon_romance")
                        
                        Button(action: {
                            weakSelf.doWork("photo2cartoon_colorful")
                        }, label: {
                            ProSelectView(name: "photo2cartoon_colorful.jpg", title:"photo2cartoon_colorful",
                                          selected: self.$selectedName)
                        }).padding(5)
                        .disabled(working)
                        .scrollId("photo2cartoon_colorful")
                        
                        HStack {
                            Button(action: {
                                weakSelf.doWork("hayao")
                            }, label: {
                                ProSelectView(name: "IMG_0008.JPG", title:"hayao",
                                              selected: self.$selectedName)
                            }).padding(5)
                            .disabled(working)
                            .scrollId("hayao")
                            
                            Button(action: {
                                weakSelf.doWork("paprika")
                            }, label: {
                                ProSelectView(name: "IMG_0009.JPG", title:"paprika",
                                              selected: self.$selectedName)
                            }).padding(5)
                            .disabled(working)
                            .scrollId("paprika")
                            
                            Button(action: {
                                weakSelf.doWork("chayao8")
                            }, label: {
                                ProSelectView(name: "IMG_0010.JPG", title:"chayao8",
                                              selected: self.$selectedName)
                            }).padding(5)
                            .disabled(working)
                            .scrollId("chayao8")
                            
                            Button(action: {
                                weakSelf.doWork("cpaprika8")
                            }, label: {
                                ProSelectView(name: "IMG_0011.JPG", title:"cpaprika8",
                                              selected: self.$selectedName)
                            }).padding(5)
                            .disabled(working)
                            .scrollId("cpaprika8")
                            
                            Button(action: {
                                weakSelf.doWork("chosoda8")
                            }, label: {
                                ProSelectView(name: "IMG_0012.JPG", title:"chosoda8",
                                              selected: self.$selectedName)
                            }).padding(5)
                            .disabled(working)
                            .scrollId("chosoda8")
                            
                            Button(action: {
                                weakSelf.doWork("warpgan8")
                            }, label: {
                                ProSelectView(name: "IMG_0013.JPG", title:"warpgan8",
                                              selected: self.$selectedName)
                            }).padding(5)
                            .disabled(working)
                            .scrollId("warpgan8")
                        }
                        
                        HStack {
                            Button(action: {
                                weakSelf.doWork("style_rain_princess")
                            }, label: {
                                ProSelectView(name: "style_rain_princess.jpg", title:"style_rain_princess",
                                              selected: self.$selectedName)
                            }).padding(5)
                            .scrollId("style_rain_princess")
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
                                weakSelf.doWork("style_udnie")
                            }, label: {
                                ProSelectView(name: "style_udnie.jpg", title:"style_udnie",
                                              selected: self.$selectedName)
                            }).padding(5)
                            .scrollId("style_udnie")
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

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ImageView(name: "hayao",
                image: .constant(UIImage()),
                working: .constant(false),
                showNow: .constant(true),
                cartoon: .constant(UIImage()),
                glass: .constant(UIImage()),
                glassFace: .constant(false),
                thinFace: .constant(true),
                delegateFx: nil)
        }.onAppear() {
        }
    }
}
