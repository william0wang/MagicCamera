//
//  CameraView.swift
//  TestApp
//
//  Created by William on 2020/12/12.
//

import SwiftUI

struct StyleCameraView: View, CameraFxImage {
    @State private var imageActive = false
    @State private var working = false
    @State private var showNow = false
    @State private var image = UIImage()
    @State private var face = UIImage()
    @State private var faceInfo :FaceInfo?
    private var CmUtil: CoreMLUtils?
    private var fxName: String = "aged"
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
                weakSelf.CmUtil?.DoFX(name:fx, face: weakSelf.faceInfo!) { image in
                    weakSelf.image = image
                    DispatchQueue.main.async {
                        weakSelf.showNow = true
                        weakSelf.working = false
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
    
    public init(CmUtil: CoreMLUtils?, fxName:String = "aged") {
        self.CmUtil = CmUtil
        self.fxName = fxName
    }
    
    var body: some View {
        HeaderZStack(title: "StyleTab") {
            LiveCameraFilterView(events: events, delegateFx: self, level:2)
            NavigationLink(destination: StyleImageView(name:fxName, image:$image, working: $working, showNow: $showNow, delegateFx: self), isActive: $imageActive) {
                EmptyView()
            }
        }
    }
}
