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

class ThinFaceOperation: BasicOperation {
    
    private var maskDrawingIndicies: [UInt32]?
    private var maskTexture: Texture!
    private var outputSize: CGSize = .zero
    private var vertexBuffer: MTLBuffer?
    private var textureBuffer: MTLBuffer?
    private var maskIndexsBuffer: MTLBuffer?
    
    init() {
        super.init(fragmentFunctionName: "passthroughFragment")
    }

    func setupData(image: UIImage, landmarks: [CGPoint], toPoints: [CGPoint]) {
        createMaskTexture(image:image)
        self.outputSize = image.size
        let patternW = Int(image.size.width)
        let patternH = Int(image.size.height)
        guard let checkMlsMesh = MLSMesh(width: patternW, andHeight: patternH) else {
            return
        }
        checkMlsMesh.setup(withRows: 100, andCols: 100)
        checkMlsMesh.doMovingLeastSquareDefrom(from: landmarks, to: toPoints)
        guard let maskDrawingIndicies = checkMlsMesh.trianglesIndices as? [UInt32], var overriddenVertices = checkMlsMesh.deformedPoints as? [CGPoint], var overriddenTextureCoordinates = checkMlsMesh.originPoints as? [CGPoint] else {
            return
        }
        self.maskDrawingIndicies = maskDrawingIndicies
        self.maskIndexsBuffer = sharedMetalRenderingDevice.device.makeBuffer(bytes: maskDrawingIndicies, length: MemoryLayout<UInt32>.size * maskDrawingIndicies.count, options: .storageModeShared)
        overriddenVertices = self.worldCoordinateToVertexs(points: overriddenVertices, in: image.size)
        overriddenTextureCoordinates = self.worldCoordinateToTextureCoordsCGPoint(points: overriddenTextureCoordinates, in: image.size)
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
    
    private func createMaskTexture(image: UIImage) {
        do {
            let maskMTKTexture = try MTKTextureLoader(device: sharedMetalRenderingDevice.device).newTexture(cgImage: image.cgImage!, options: [.SRGB: false])
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
}
