//
//  BeautyImageView.swift
//  MagicCamera
//
//  Created by William on 2020/12/30.
//

import SwiftUI

struct BeautyImageItemView: View {
    private var title: String
    private var action: () -> Void
    private var canUse: Bool = true
    @Binding var selectedName : String
    
    public init(title: String, selected: Binding<String>, action: @escaping () -> Void) {
        self.title = title
        self.action = action
        self._selectedName = selected
        self.canUse = DefaultsKeys.CanFxUse(name: title)
    }
    
    var body: some View {
        Button(action: action, label: {
            ProSelectAutoView(name: title + ".jpg", title:title, selected: $selectedName)
        })
    }
}

struct BeautyImageView: View {
    @Binding var origin: UIImage
    @Binding var image: UIImage
    @Binding var thin: UIImage
    @Binding var working: Bool
    @Binding var showNow: Bool
    @Binding var thinFace: Bool
    @State private var selectedName : String
    @State var savePopup = false
    @State var savePopupOk = false
    @State var saveError : Error?
    @State var idx: Int = -1
    private var lastThin = false
    public var delegateFx: CameraFxImage?
    let width = UIScreen.main.bounds.width-10
    let height = UIScreen.main.bounds.height-300

    private func savePhoto() {
        let imageSaver = ImageSaver(action: { ok, error in
            self.savePopupOk = ok
            self.saveError = error
            self.savePopup = true
        })
        imageSaver.writeToPhotoAlbum(image: image)
    }
    
    public init(name: String, origin: Binding<UIImage>, image: Binding<UIImage>, thin: Binding<UIImage>, thinFace: Binding<Bool>, working: Binding<Bool>, showNow: Binding<Bool>, idx:Int, delegateFx: CameraFxImage?) {
        self._selectedName = State(initialValue: name)
        self._idx = State(initialValue: idx)
        self._origin = origin
        self._image = image
        self._thin = thin
        self._thinFace = thinFace
        self._working = working
        self._showNow = showNow
        self.delegateFx = delegateFx
        self.lastThin = self.thinFace
    }
    
    private mutating func doWork(_ name: String) {
        if selectedName == name {
            if lastThin == thinFace {
                return
            }
            lastThin = thinFace
        }
        self.idx = -1
        self.working = true
        var weakSelf = self
        DispatchQueue.global().async {
            weakSelf.delegateFx?.doFx(name)
            DispatchQueue.main.async {
                weakSelf.selectedName = name
                weakSelf.showNow = true
            }
        }
    }
    
    private mutating func doMTWork(_ name: String, idx: Int) {
        if selectedName == name {
            if lastThin == thinFace {
                return
            }
            lastThin = thinFace
        }
        
        self.working = true
        self.idx = idx
        let weakSelf = self
        DispatchQueue.init(label: "fx").async{
            var image = weakSelf.origin
            if weakSelf.thinFace {
                image = weakSelf.thin
            }
            let filter = DefaultsKeys.getFilterAtIndex(weakSelf.idx)
            weakSelf.image = mtFilterImage(image, filter: filter)
            DispatchQueue.main.async {
                weakSelf.selectedName = name
                weakSelf.working = false
                weakSelf.showNow = true
            }
        }
    }
    
    var body: some View {
        var weakSelf = self
        HeaderStack(title: "BeautyCam") {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
            }.popup(isPresented: $savePopup, autohideIn: 3) {
                ImageSaveView(savePopupOk: self.$savePopupOk, saveError: self.$saveError)
            }
            HStack {
                Button(action: {
                    weakSelf.savePhoto()
                }, label: {
                    Text("SaveFile")
                }).disabled(working)
                .padding(.leading, 10)
                Spacer()
                Toggle("thin", isOn:$thinFace)
                    .onReceive([self.thinFace].publisher.first()) { (value) in
                        if self.idx < 0 {
                            weakSelf.doWork(selectedName)
                        } else {
                            weakSelf.doMTWork(selectedName, idx:self.idx)
                        }
                    }
                    .toggleStyle(CheckboxStyle())
                    .frame(width: 70, height: 30)
                    .padding(.trailing, 10)
                    .disabled(working)
            }
            Spacer()
            ScrollView(.horizontal) { proxy in
                HStack {
                    Button(action: {
                        weakSelf.doWork("origin")
                    }, label: {
                        ProSelectView(name: "face.jpg", title:"origin",
                                      selected: self.$selectedName, pro: false)
                    })
                    .disabled(working)
                    .scrollId("origin")

                    BeautyImageItemView(title:"fleeting", selected: self.$selectedName, action: {
                        weakSelf.doWork("fleeting")
                    }).padding(.leading, 5)
                    .scrollId("fleeting")
                    .disabled(working)

                    BeautyImageItemView(title:"hdr", selected: self.$selectedName, action: {
                        weakSelf.doWork("hdr")
                    }).padding(.leading, 5)
                    .scrollId("hdr")
                    .disabled(working)

                    BeautyImageItemView(title:"kuwahara", selected: self.$selectedName, action: {
                        weakSelf.doWork("kuwahara")
                    }).padding(.leading, 5)
                    .scrollId("kuwahara")
                    .disabled(working)

                    BeautyImageItemView(title:"pixellate", selected: self.$selectedName, action: {
                        weakSelf.doWork("pixellate")
                    }).padding(.leading, 5)
                    .scrollId("pixellate")
                    .disabled(working)
                    
                    BeautyImageItemView(title:"toon", selected: self.$selectedName, action: {
                        weakSelf.doWork("toon")
                    }).padding(.leading, 5)
                    .scrollId("toon")
                    .disabled(working)
                    
                    BeautyImageItemView(title:"lomo", selected: self.$selectedName, action: {
                        weakSelf.doWork("lomo")
                    }).padding(.leading, 5)
                    .scrollId("lomo")
                    .disabled(working)
                    
                    HStack {
                        ForEach(0 ..< DefaultsKeys.allFilters.count){ idx in
                            let filter = DefaultsKeys.getFilterAtIndex(idx)
                            let name = DefaultsKeys.allFilters[idx].name
                            
                            Button(action: {
                                DispatchQueue.global().async {
                                    weakSelf.doMTWork(name, idx:idx)
                                }
                            }, label: {
                                ProSelectView(name: "face.jpg", title:name,
                                              selected: self.$selectedName, pro: true,
                                              filter:filter, resize:CGSize(width: 128, height: 128))
                            }).padding(.leading, 5)
                            .scrollId(name)
                            .disabled(working)
                        }
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

struct BeautyImageView_Previews: PreviewProvider {
    static var previews: some View {
        BeautyImageView(name: "origin",
                        origin: .constant(UIImage()),
                        image: .constant(UIImage()),
                        thin: .constant(UIImage()),
                        thinFace: .constant(true),
                        working: .constant(false),
                        showNow: .constant(true),
                        idx: -1,
                        delegateFx: nil)
    }
}
