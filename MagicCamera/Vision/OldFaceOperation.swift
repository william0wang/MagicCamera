//
//  OldFaceOperation.swift
//  Old Face Sample
//
//  Created by 马陈爽 on 2020/9/19.
//  Copyright © 2020 马陈爽. All rights reserved.
//

import Foundation
import GPUImage
import UIKit
import MetalKit

class OldFaceOperation: BasicOperation {
    
    private let maskImage = UIImage(named: "Age90.png")!
    private var maskDrawingIndicies: [UInt32]?
    private var maskTexture: Texture!
    private var outputSize: CGSize = .zero
    private var vertexBuffer: MTLBuffer?
    private var textureBuffer: MTLBuffer?
    private var maskIndexsBuffer: MTLBuffer?
    
    init() {
        super.init(fragmentFunctionName: "passthroughFragment")
        createMaskTexture()
    }

    func setupData(landmarks: [CGPoint], inputSize: CGSize) {
        self.outputSize = inputSize
        let patternW = Int(self.maskImage.size.width)
        let patternH = Int(self.maskImage.size.height)
        guard let checkMlsMesh = MLSMesh(width: patternW, andHeight: patternH) else {
            return
        }
        checkMlsMesh.setup(withRows: 100, andCols: 100)
        let controlPoints = getControlPoints()
        checkMlsMesh.doMovingLeastSquareDefrom(from: controlPoints, to: landmarks)
        guard let maskDrawingIndicies = checkMlsMesh.trianglesIndices as? [UInt32], var overriddenVertices = checkMlsMesh.deformedPoints as? [CGPoint], var overriddenTextureCoordinates = checkMlsMesh.originPoints as? [CGPoint] else {
            return
        }
        self.maskDrawingIndicies = maskDrawingIndicies
        self.maskIndexsBuffer = sharedMetalRenderingDevice.device.makeBuffer(bytes: maskDrawingIndicies, length: MemoryLayout<UInt32>.size * maskDrawingIndicies.count, options: .storageModeShared)
        overriddenVertices = self.worldCoordinateToVertexs(points: overriddenVertices, in: inputSize)
        overriddenTextureCoordinates = self.worldCoordinateToTextureCoordsCGPoint(points: overriddenTextureCoordinates, in: self.maskImage.size)
        let vertexArray = pointsToFloatArray(overriddenVertices)
        let inputTextureCoordinates = pointsToFloatArray(overriddenTextureCoordinates)
        self.vertexBuffer = sharedMetalRenderingDevice.device.makeBuffer(bytes: vertexArray, length: vertexArray.count * MemoryLayout<Float>.size, options: [])
        self.textureBuffer = sharedMetalRenderingDevice.device.makeBuffer(bytes: inputTextureCoordinates, length: inputTextureCoordinates.count * MemoryLayout<Float>.size, options: [])
    }
    
    override func newTextureAvailable(_ texture: Texture, fromSourceIndex: UInt) {
        let _ = textureInputSemaphore.wait(timeout:DispatchTime.distantFuture)
        defer {
            textureInputSemaphore.signal()
        }
        
        let outputWidth:Int = Int(outputSize.width)
            let outputHeight:Int = Int(outputSize.height)

            
            guard let commandBuffer = sharedMetalRenderingDevice.commandQueue.makeCommandBuffer() else {return}

            let outputTexture = Texture(device:sharedMetalRenderingDevice.device, orientation: .portraitUpsideDown, width: outputWidth, height: outputHeight, timingStyle: self.maskTexture.timingStyle)
            
            guard let vertexBuffer = self.vertexBuffer, let textureBuffer = self.textureBuffer, let indexBuffer = self.maskIndexsBuffer, let maskDrawingIndicies = self.maskDrawingIndicies else {
                return
            }
            let renderPass = MTLRenderPassDescriptor()
            renderPass.colorAttachments[0].texture = outputTexture.texture
            renderPass.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
            renderPass.colorAttachments[0].storeAction = .store
            renderPass.colorAttachments[0].loadAction = .clear
            
            guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPass) else {
                fatalError("Could not create render encoder")
            }
            
            renderEncoder.setFrontFacing(.counterClockwise)
            renderEncoder.setRenderPipelineState(renderPipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderEncoder.setVertexBuffer(textureBuffer, offset: 0, index: 1)
            renderEncoder.setFragmentTexture(self.maskTexture.texture, index: 0)
            renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: maskDrawingIndicies.count, indexType: .uint32, indexBuffer: indexBuffer, indexBufferOffset: 0)
            renderEncoder.endEncoding()
            commandBuffer.commit()
            removeTransientInputs()
            textureInputSemaphore.signal()
            updateTargetsWithTexture(outputTexture)
            let _ = textureInputSemaphore.wait(timeout:DispatchTime.distantFuture)
    }
    
    private func pointsToFloatArray(_ points: [CGPoint]) -> [Float] {
        var array = [Float]()
        for (_, item) in points.enumerated() {
            array.append(Float(item.x))
            array.append(Float(item.y))
        }
        return array
    }
    
    private func createMaskTexture() {
        do {
            let maskMTKTexture = try MTKTextureLoader(device: sharedMetalRenderingDevice.device).newTexture(cgImage: self.maskImage.cgImage!, options: [.SRGB: false])
            self.maskTexture = Texture(orientation: .portrait, texture: maskMTKTexture)
        } catch let error {
            debugPrint("\(error)")
        }
    }
    
    private func worldCoordinateToVertexs(points: [CGPoint], in containerSize: CGSize) -> [CGPoint] {
        var result = [CGPoint]()
        for (_, point) in points.enumerated() {
            result.append(CGPoint(x: 2.0 * point.x / containerSize.width - 1.0, y: 2.0 * point.y / containerSize.height - 1.0 ))
        }
        return result
    }
    
    private func worldCoordinateToTextureCoordsCGPoint(points: [CGPoint], in containerSize: CGSize) -> [CGPoint] {
        var result = [CGPoint]()
        for (_, point) in points.enumerated() {
            result.append(CGPoint(x: point.x / containerSize.width, y: point.y / containerSize.height))
        }
        return result
    }
    
    private func getControlPoints() -> [CGPoint] {
        var controlPoints: [CGPoint] = []
        
        // nose
        controlPoints.append(CGPoint(x:403.5240502748901, y:466.10354671222086))
        controlPoints.append(CGPoint(x:363.1230931646322, y:480.8264839914165))
        controlPoints.append(CGPoint(x:341.1230931646322, y:517.5383160712017))
        controlPoints.append(CGPoint(x:306.2380973713965, y:567.3346926497823))
        controlPoints.append(CGPoint(x:398.61482627708915, y:594.558508434307))
        controlPoints.append(CGPoint(x:484.40758209231535, y:578.4899294928773))
        controlPoints.append(CGPoint(x:465.9386322820444, y:526.1108768652574))
        controlPoints.append(CGPoint(x:437.139833288363, y:480.7680012315394))

        // leftEye
        controlPoints.append(CGPoint(x:207.6933667940267, y:378.09135620122913))
        controlPoints.append(CGPoint(x:238.88552210609362, y:370.0126810782467))
        controlPoints.append(CGPoint(x:287.0580093428089, y:372.6245985072245))
        controlPoints.append(CGPoint(x:316.58904045910674, y:396.0238053510881))
        controlPoints.append(CGPoint(x:283.36663283745054, y:399.1598969957972))
        controlPoints.append(CGPoint(x:238.5163749188422, y:400.4512445570323))

        // leftPupil
        controlPoints.append(CGPoint(x:266.28190001370672, y:388.45021646574367))

        // leftEyebrow
        controlPoints.append(CGPoint(x:190.01556359840365, y:285.5539252363558))
        controlPoints.append(CGPoint(x:237.77809961777052, y:265.3920409452588))
        controlPoints.append(CGPoint(x:339.324313244382, y:283.2862378452077))
        controlPoints.append(CGPoint(x:325.44836314539793, y:302.34125279810314))
        controlPoints.append(CGPoint(x:239.25465021991386, y:293.2917999816284))
        controlPoints.append(CGPoint(x:203.70694487211978, y:302.15677457506956))

        // rightEye
        controlPoints.append(CGPoint(x:562.6194609704783, y:370.8382990367658))
        controlPoints.append(CGPoint(x:530.504456763714, y:360.60440614411914))
        controlPoints.append(CGPoint(x:483.2548374951273, y:370.1678988479109))
        controlPoints.append(CGPoint(x:465.569485094793, y:395.4119260689719))
        controlPoints.append(CGPoint(x:528.42274552919775, y:413.51875726031176))
        controlPoints.append(CGPoint(x:573.0884489276116, y:410.04296962290476))

        // rightPupil
        controlPoints.append(CGPoint(x:526.0944921060668, y:383.517729169023))

        // rightEyebrow
        controlPoints.append(CGPoint(x:618.7284219987873, y:262.3976412285412))
        controlPoints.append(CGPoint(x:531.6118983254682, y:254.69241844989625))
        controlPoints.append(CGPoint(x:443.3879330903949, y:281.84420655944047))
        controlPoints.append(CGPoint(x:459.2941354989682, y:291.5448571460918))
        controlPoints.append(CGPoint(x:531.9810073658573, y:281.77665570929935))
        controlPoints.append(CGPoint(x:616.5136151690035, y:286.1849687902886))

        // innerLips
        controlPoints.append(CGPoint(x:319.257746373317, y:653.5526009116325))
        controlPoints.append(CGPoint(x:391.0913768792325, y:665.3973640685374))
        controlPoints.append(CGPoint(x:461.9718871074301, y:661.125180779119))
        controlPoints.append(CGPoint(x:455.9249883117168, y:684.2139330102233))
        controlPoints.append(CGPoint(x:396.82963310687296, y:683.4377487947481))
        controlPoints.append(CGPoint(x:323.5194710722453, y:673.379266034871))

        //outerLips
        controlPoints.append(CGPoint(x:292.91431043987245, y:638.4356544653091))
        controlPoints.append(CGPoint(x:341.32129165515437, y:639.6392588132976))
        controlPoints.append(CGPoint(x:373.8054239757389, y:638.4255582837563))
        controlPoints.append(CGPoint(x:398.72222969198106, y:635.1150845975662))
        controlPoints.append(CGPoint(x:423.8236280752801, y:636.9497515729186))
        controlPoints.append(CGPoint(x:453.7237873053982, y:636.2118386807842))
        controlPoints.append(CGPoint(x:485.4696443249111, y:637.687645391622))
        controlPoints.append(CGPoint(x:506.108097929532, y:631.0082152593648))
        controlPoints.append(CGPoint(x:486.9461949270544, y:697.9034593240332))
        controlPoints.append(CGPoint(x:446.34103429468155, y:709.3611775379201))
        controlPoints.append(CGPoint(x:400.5679274813758, y:709.3228966778638))
        controlPoints.append(CGPoint(x:353.31827006592675, y:722.5265105625679))
        controlPoints.append(CGPoint(x:328.83715933456983, y:712.7583186624909))
        controlPoints.append(CGPoint(x:295.4301781192879, y:692.8146880194981))

        // faceContour
        controlPoints.append(CGPoint(x:682.6558310226983, y:351.3039904926201)) //0
        controlPoints.append(CGPoint(x:694.501528812093, y:425.6479132910576))  //1
        controlPoints.append(CGPoint(x:679.7027298184116, y:500.7297489816294)) //2
        controlPoints.append(CGPoint(x:665.4743171651626, y:575.6270683023059)) //3
        controlPoints.append(CGPoint(x:656.8025705882935, y:648.310706166872))  //4
        controlPoints.append(CGPoint(x:632.673960558064, y:712.8773689749686))  //5
        controlPoints.append(CGPoint(x:606.2563569616821, y:767.4823269481946)) //6
        controlPoints.append(CGPoint(x:504.34859693969156, y:833.7566164879462))//7
        
        controlPoints.append(CGPoint(x:398.25932306016534, y:868.5731887078781))//8
        
        controlPoints.append(CGPoint(x:260.0323171624332, y:824.2909023823928)) //9
        controlPoints.append(CGPoint(x:189.0338002116748, y:778.9198527989761)) //10
        controlPoints.append(CGPoint(x:151.23345314129182, y:729.1112809410461))//11
        controlPoints.append(CGPoint(x:132.16836455111067, y:667.4962220179098))//12
        controlPoints.append(CGPoint(x:120.0987531138037, y:595.5505065821933)) //13
        controlPoints.append(CGPoint(x:108.4875469187967, y:519.9152552959516)) //14
        controlPoints.append(CGPoint(x:96.99812920124273, y:443.1731537449393)) //15
        controlPoints.append(CGPoint(x:91.92248293010667, y:366.98448686302766))//16
        
        return controlPoints
    }
}
