//
//  BeauteyCameraView.swift
//  MagicCamera
//
//  Created by William on 2020/12/30.
//

import SwiftUI

struct BeautyCameraView: View , CameraFxImage {
    @State private var imageActive = false
    @State private var working = false
    @State private var showNow = false
    @State private var thinFace = true
    @State private var image = UIImage()
    @State private var origin = UIImage()
    @State private var thin = UIImage()
    private var idx: Int = -1
    private var CmUtil: CoreMLUtils?
    private var fxName: String = "origin"
    @ObservedObject  var events = UserEvents()
    @Environment(\.presentationMode) var presentationMode
    private var cameraView : LiveCameraFilterView?
    
    mutating func doFx(_ fx: String) {
        let weakSelf = self
        
        self.working = true
        DispatchQueue.init(label: "fx").async{
            debugPrint("doFx", fx)
            if !DefaultsKeys.IsFxTry(name: fx) {
                DefaultsKeys.SetFxTry(name: fx)
            }
            if fx == "origin" {
                if weakSelf.thinFace {
                    weakSelf.image = weakSelf.thin
                } else {
                    weakSelf.image = weakSelf.origin
                }
            } else {
                var image = weakSelf.origin
                if weakSelf.thinFace {
                    image = weakSelf.thin
                }
                weakSelf.image = StyleImage(style:fx, image:image)
            }
            DispatchQueue.main.async {
                weakSelf.showNow = true
                weakSelf.working = false
            }
        }
    }
    
    mutating func doMtFx(idx : Int) {
        let weakSelf = self
        
        self.working = true
        DispatchQueue.init(label: "fx").async{
            var image = weakSelf.origin
            if weakSelf.thinFace {
                image = weakSelf.thin
            }
            let filter = DefaultsKeys.getFilterAtIndex(idx)
            weakSelf.image = mtFilterImage(image, filter: filter)
            DispatchQueue.main.async {
                weakSelf.showNow = true
                weakSelf.working = false
            }
        }
    }
    
    mutating func didImageOk(_ image: UIImage) {
        var weakSelf = self
        DispatchQueue.init(label: "face").async{
            weakSelf.origin = image
            weakSelf.image = weakSelf.origin
            weakSelf.imageActive = true
            weakSelf.working = true
            weakSelf.CmUtil?.DoFaceThin(uiImage: image) { image in
                weakSelf.thin = image
                if weakSelf.idx >= 0 {
                    weakSelf.doMtFx(idx: weakSelf.idx)
                } else {
                    weakSelf.doFx(weakSelf.fxName)
                }
            }
        }
    }
    
    public init(CmUtil: CoreMLUtils?, fxName:String = "origin", idx:Int = -1) {
        self.CmUtil = CmUtil
        self.fxName = fxName
        self.idx = idx
    }
    
    var body: some View {
        HeaderZStack(title: "BeautyCam") {
            LiveCameraFilterView(events: events, delegateFx: self, face: false, level:3)
            NavigationLink(destination: BeautyImageView(
                            name:fxName, origin:$origin, image:$image,
                            thin:$thin, thinFace: $thinFace,
                            working: $working, showNow: $showNow, idx:idx,
                            delegateFx: self), isActive: $imageActive) {
                EmptyView()
            }
        }
    }
}
