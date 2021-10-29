//
//  CameraPhotoFilterVC.swift
//  MagicCamera
//
//  Created by William on 2020/12/28.
//
import SwiftUI
import UIKit
import AVFoundation
import BBMetalImage

class CameraPhotoFilterVC: UIViewController {
    private var camera: BBMetalCamera!
    private var metalView: BBMetalView!
    public var delegateFx: CameraFxImage?
    public var level: Int = 3
    public var position: AVCaptureDevice.Position = .front
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view.backgroundColor = .white
        
        var smooth = Float(0.5)
        var brightness = Float(0.01)
        var preset = AVCaptureSession.Preset.photo
        switch(level) {
        case 0:
            smooth = Float(0.5)
            brightness = Float(0.001)
            preset = .hd1920x1080
            break;
        case 1:
            smooth = Float(0.5)
            brightness = Float(0.01)
            preset = .hd1920x1080
            break;
        case 2:
            smooth = Float(0.65)
            brightness = Float(0.025)
            preset = .hd1920x1080
            break;
        default:
            smooth = Float(0.75)
            brightness = Float(0.03)
            preset = .hd1920x1080
            break;
        }
        
        debugPrint(position.rawValue)
        camera = BBMetalCamera(sessionPreset: preset, position: position)
        if camera == nil {
            camera = BBMetalCamera(sessionPreset: .high, position: position)
        }
        
        let x: CGFloat = 0
        let width: CGFloat = view.bounds.width
        let height: CGFloat = min(width*4/3, view.bounds.height*2/3)
        
        metalView = BBMetalView(frame: CGRect(x: x, y: 0, width: width, height: height))
        metalView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        metalView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.addSubview(metalView)
        
        camera.canTakePhoto = true
        camera.photoDelegate = self
        
        camera
            .add(consumer: BBMetalBeautyFilter(distanceNormalizationFactor: 4, stepOffset: 4, edgeStrength: 1, smoothDegree: smooth))
            .add(consumer: BBMetalBrightnessFilter(brightness: brightness))
            .add(consumer: metalView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        camera.start()
        metalView.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        camera.stop()
    }
    
    public func switchCameraPosition()  {
        camera.switchCameraPosition()
    }
    
    public func takePhoto()  {
        metalView.isHidden = true
        camera.takePhoto()
    }
}

extension CameraPhotoFilterVC: BBMetalCameraPhotoDelegate {
    func camera(_ camera: BBMetalCamera, didOutput texture: MTLTexture) {
        // In main thread
        var smooth = Float(0.5)
        var bright = Float(0.01)
        switch(level) {
        case 0:
            smooth = Float(0.5)
            bright = Float(0.001)
            break;
        case 1:
            smooth = Float(0.5)
            bright = Float(0.01)
            break;
        case 2:
            smooth = Float(0.65)
            bright = Float(0.025)
            break;
        default:
            smooth = Float(0.75)
            bright = Float(0.03)
            break;
        }
        let brightness = BBMetalBrightnessFilter(brightness: bright)
        let imageSource = BBMetalStaticImageSource(image: texture.bb_image!)
        // Set up filter chain
        // Make last filter run synchronously
        imageSource.add(consumer: BBMetalBeautyFilter(distanceNormalizationFactor: 4, stepOffset: 4, edgeStrength: 1, smoothDegree: smooth))
            .add(consumer: brightness)
            .runSynchronously = true

        // Start processing
        imageSource.transmitTexture()
        // Get filtered image
        guard let filteredImage = brightness.outputTexture?.bb_image else { return  }
        
        metalView.isHidden = false
        DispatchQueue.main.async {
            self.delegateFx?.didImageOk(filteredImage)
        }
    }
    
    func camera(_ camera: BBMetalCamera, didFail error: Error) {
        // In main thread
        debugPrint("Fail taking photo. Error: \(error)")
    }
}

struct CameraPhotoFilterView: UIViewControllerRepresentable {
    @ObservedObject var events: UserEvents
//    @Environment(\.presentationMode)
//    private var presentationMode
    private var level: Int
    private var position: AVCaptureDevice.Position = .front
    private var delegateFx: CameraFxImage?
    
    typealias UIViewControllerType = CameraPhotoFilterVC
    func makeUIViewController(context: Context) -> CameraPhotoFilterVC {
        let vc = CameraPhotoFilterVC()
        vc.delegateFx = self.delegateFx
        vc.level = self.level
        vc.position = self.position
        return vc
    }
    
    func updateUIViewController(_ cameraController: CameraPhotoFilterVC, context: Context) {
        if events.didAskToCapturePhoto {
            events.didAskToCapturePhoto = false
            cameraController.takePhoto()
        }
        
        if events.didAskToRotateCamera {
            events.didAskToRotateCamera = false
            cameraController.switchCameraPosition()
        }
    }
    
    public init(events: UserEvents, delegateFx: CameraFxImage?, level: Int = 1, position: AVCaptureDevice.Position = .front) {
        self.events = events
        self.delegateFx = delegateFx
        self.level = level
        self.position = position
    }
}
