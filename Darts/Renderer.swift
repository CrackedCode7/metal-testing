//
//  Renderer.swift
//  Darts
//
//  Created by Evan Rinehart on 1/3/24.
//

import MetalKit

struct Vertex {
    var position: SIMD3<Float>
    var color: SIMD3<Float>
}

class Renderer: NSObject, MTKViewDelegate {
    
    var parent: ContentView
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    let pipelineState: MTLRenderPipelineState
    let vertexBuffer: MTLBuffer!

    init(_ parent: ContentView) {
        
        self.parent = parent
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        let library = metalDevice.makeDefaultLibrary()!
        //let vertexProgram = library.makeFunction(name: "basic_vertex")
        //let fragmentProgram = library.makeFunction(name: "basic_fragment")
        let vertexProgram = library.makeFunction(name: "colored_vertex")
        let fragmentProgram = library.makeFunction(name: "colored_fragment")
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            try pipelineState = metalDevice.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch {
            fatalError()
        }
        
        /*let vertexData: [Float] = [
            0.0, 0.5, 0.0,
            -1.0, -0.5, 0.0,
            1.0, -0.5, 0.0
        ]*/
        
        let vertices = [
            Vertex(position: [0.0, 0.5, 0.0], color: [1.0, 0.0, 0.0]),
            Vertex(position: [-1.0, -0.5, 0.0], color: [0.0, 1.0, 0.0]),
            Vertex(position: [1.0, -0.5, 0.0], color: [0.0, 0.0, 1.0])
        ]

        //let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        //vertexBuffer = metalDevice.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        let dataSize = vertices.count * MemoryLayout<Vertex>.stride
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: dataSize, options: [])
        
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let commandBuffer = metalCommandQueue.makeCommandBuffer()
        
        let renderPassDescriptor = view.currentRenderPassDescriptor
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColor(
            red: 0.0,
            green: 0.4,
            blue: 0.0,
            alpha: 1.0)
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        
        renderEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
