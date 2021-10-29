//
//  CameraView.swift
//  TestApp
//
//  Created by William on 2020/12/12.
//

import SwiftUI
import AVFoundation

struct LiveCameraView: View, CameraFxImage {
    @State private var imageActive = false
    @State private var working = false
    @State private var showNow = false
    @State private var image = UIImage()
    @State private var cartoon = UIImage()
    @State private var face = UIImage()
    @State private var glass = UIImage()
    @State private var glassFace = false
    @State private var thinFace = true
    @State private var faceInfo :FaceInfo?
    private var CmUtil: CoreMLUtils?
    private var fxName: String = "photo2cartoon"
    private var showFace: Bool = true
    private var position: AVCaptureDevice.Position = .front
    @ObservedObject  var events = UserEvents()
    @Environment(\.presentationMode) var presentationMode
    private var cameraView : LiveCameraFilterView?
    
    mutating func doFx(_ fx: String) {
        let weakSelf = self
        self.working = true
        DispatchQueue.init(label: "fx").async{
            weakSelf.image = weakSelf.face
            if fx == "aged" {
                weakSelf.CmUtil?.DoFaceOld(uiImage: weakSelf.face) { image in
                    weakSelf.image = image
                    DispatchQueue.main.async {
                        weakSelf.showNow = true
                        weakSelf.working = false
                    }
                }
            } else {
                if weakSelf.thinFace {
                    weakSelf.CmUtil?.DoFaceThin(uiImage: weakSelf.face, completionHandler: { thinface in
                        weakSelf.image = thinface
                        weakSelf.faceInfo!.image = thinface
                        weakSelf.CmUtil?.DoFX(name:fx, face: weakSelf.faceInfo!) { image in
                            weakSelf.cartoon = image
                            weakSelf.CmUtil?.DoGlassFace(uiImage: weakSelf.face, cartoon: image, completionHandler: { image in
                                weakSelf.glass = image
                                if weakSelf.glassFace {
                                    weakSelf.image = weakSelf.glass
                                } else {
                                    weakSelf.image = weakSelf.cartoon
                                }
                                DispatchQueue.main.async {
                                    weakSelf.showNow = true
                                    weakSelf.working = false
                                }
                            })
                        }
                    })
                } else {
                    weakSelf.faceInfo!.image = weakSelf.face
                    weakSelf.CmUtil?.DoFX(name:fx, face: weakSelf.faceInfo!) { image in
                        weakSelf.cartoon = image
                        weakSelf.CmUtil?.DoGlassFace(uiImage: weakSelf.face, cartoon: image, completionHandler: { image in
                            weakSelf.glass = image
                            if weakSelf.glassFace {
                                weakSelf.image = weakSelf.glass
                            } else {
                                weakSelf.image = weakSelf.cartoon
                            }
                            DispatchQueue.main.async {
                                weakSelf.showNow = true
                                weakSelf.working = false
                            }
                        })
                    }
                }
            }
        }
    }
    
    mutating func didImageOk(_ image: UIImage) {
        var weakSelf = self
        DispatchQueue.init(label: "face").async{
            weakSelf.faceInfo = corpFace(image)
            weakSelf.face = weakSelf.faceInfo!.image
            weakSelf.image = weakSelf.face
            DispatchQueue.main.async {
                weakSelf.imageActive = true
            }
            weakSelf.doFx(weakSelf.fxName)
        }
    }
    
    public init(CmUtil: CoreMLUtils?, fxName:String = "photo2cartoon") {
        self.CmUtil = CmUtil
        self.fxName = fxName
//        if fxName == "warpgan8" {
//            self.showFace = false
//            self.position = .back
//        }
    }
    
    var body: some View {
        HeaderZStack(title: "CartoonTab") {
            LiveCameraFilterView(events: events, delegateFx: self, face: showFace, level:2, position: position)
            NavigationLink(destination: ImageView(name:fxName, image:$image, working: $working, showNow: $showNow,
                                                  cartoon: $cartoon, glass: $glass, glassFace: $glassFace, thinFace: $thinFace,
                                                  delegateFx: self), isActive: $imageActive) {
                EmptyView()
            }
        }
    }
}
