//
//  ViewController.swift
//  Darts
//
//  Created by Evan Rinehart on 1/3/24.
//

import UIKit
import Metal

class ViewController: UIViewController {
    // device has to be an optional (!) because it is not initialized in the initializer stage, but in a function
    // implicitly unwrapped optional
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: CADisplayLink!
    
    let vertexData: [Float] = [
        0.0, 1.0, 0.0,
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0
    ]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // BELOW ARE THE SEVEN STEPS TO SET UP METAL SO YOU CAN BEGIN RENDERING
        
        // Step 1: Creating an MTLDevice
        
        // MTLCreateSystemDefaultDevice returns a references to the default MTLDevice your code should use.
        device = MTLCreateSystemDefaultDevice()
        
        // Step 2: Creating a CAMetalLayer
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        // 8 bytes for blue, green, red, alpha, in that order. Normalized between 0 and 1
        metalLayer.pixelFormat = .bgra8Unorm
        /*
         Apple encourages you to set framebufferOnly to true for performance reasons unless you need to sample from the textures 
         generated for this layer, or if you need to enable compute kernels on the layer drawable texture. Most of the time, you
         don’t need to do this.
         */
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        // Step 3: Creating a Vertex Buffer
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        // Step 4: Creating a Vertex Shader
        // See Shaders.metal
        
        // Step 5: Creating a Fragment Shader
        // See Shaders.metal
        
        // Step 6: Creating a Render Pipeline
        
        // Access the pre-compiled shaders we made. Stored in a MTLLibrary object
        let defaultLibrary = device.makeDefaultLibrary()!
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        
        // Set up render pipeline configuration.
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // Compile the pipeline configuration
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        // Step 7: Creating a Command Queue
        
        commandQueue = device.makeCommandQueue()
        
        
        // BELOW ARE THE FIVE STEPS TO SET UP RENDERING
        
        // Step 1: Creating a Display Link
        
        // This sets up the code to call gameloop every time the screen refreshes
        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer.add(to: RunLoop.main, forMode: .default)
    }
    
    func render() {
        
        // Step 2 of RENDERING: Creating a Render Pass Descriptor
        
        // First call nextDrawable on the metal layer we selected earlier, which returns the texture to draw
        guard let drawable = metalLayer?.nextDrawable() else { return }
        // Next configure the render pass descriptor to use that texture
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
            red: 0.0,
            green: 104.0/255.0,
            blue: 55.0/255.0,
            alpha: 1.0)
        
        // Step 3 of RENDERING: Creating a Command Buffer
        
        // Holds render commands which will only happen once commited
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        // Step 4 of RENDERING: Creating a Render Command Encoder
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder
          .drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        renderEncoder.endEncoding()
        
        // Step 4 of RENDERING: Commmitting Your Command Buffer
        
        // Present the new texture as soon as drawing completes
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    @objc func gameloop() {
        autoreleasepool {
            self.render()
        }
    }
}
