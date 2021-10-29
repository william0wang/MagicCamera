//
//  LiveCameraFilterView.swift
//  MagicCamera
//
//  Created by William on 2020/12/28.
//

import SwiftUI
import Lottie
import AVFoundation

struct TackPhotoView : UIViewRepresentable {
    typealias UIViewType = AnimationView
    
    
    func makeUIView(context: Context) -> AnimationView {
        let animaView = AnimationView()
        let anima = Lottie.Animation.named("4309-take-photo")
        
        animaView.animation = anima
        animaView.loopMode = .loop
        
        animaView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        animaView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // animaView.play(fromFrame: 33, toFrame: 45)
        animaView.play()
        return animaView
    }
    
    func updateUIView(_ uiView: AnimationView, context: Context) {
        
    }
}

struct LiveCameraFilterView: View {
    @ObservedObject var events: UserEvents
    @State var openPicker  = false
    @State var takeing  = false
    var delegateFx: CameraFxImage?
    var level : Int = 1
    var position: AVCaptureDevice.Position = .front
    var showFace : Bool
    
    
    public init(events: UserEvents, delegateFx: CameraFxImage?, face:Bool = true, level:Int = 1, position: AVCaptureDevice.Position = .front) {
        self.events = events
        self.delegateFx = delegateFx
        self.level = level
        self.position = position
        self.showFace = face
    }
    
    func getPadingSize() -> CGFloat {
        return UIScreen.main.bounds.width/5
    }

    var body: some View {
        ZStack {
            CameraPhotoFilterView(events:events, delegateFx: delegateFx, level: level, position: position)
            VStack {
                if showFace && !takeing {
                    Spacer()
                    loadImage(name: "face.png")
                    .resizable()
                    .scaledToFit()
                    .padding(getPadingSize())
                }
                Spacer()
                HStack {
                    Spacer()
                    var weakself = self
                    VStack{
                        Button(action: {
                            self.openPicker = true
                        }) {
                            loadImage(name: "photo_album.png")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }.disabled(takeing)
                    }.sheet(isPresented: $openPicker) {
                        PhotoPickerView(sourceType: .photoLibrary) { image in
                            weakself.openPicker = false
                            weakself.delegateFx?.didImageOk(image)
                        }
                    }
                    Spacer()
                    Button(action: {
                        weakself.events.didAskToCapturePhoto = true
                        takeing = true
                    }, label: {
                        loadImage(name: "take_photo.png")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                    }).disabled(takeing)
                    Spacer()
                    Button(action: {
                        weakself.events.didAskToRotateCamera = true
                    }, label: {
                        loadImage(name: "rotate.png")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }).disabled(takeing)
                    Spacer()
                }
                .padding(.bottom, 10)
            }
            if takeing {
                TackPhotoView()
                .frame(width: 300, height: 300)
                .padding(.bottom, 80)
            }
        }.onAppear() {
            takeing = false
        }
    }
}
