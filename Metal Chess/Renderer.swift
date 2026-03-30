import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    private let board: Board
    private let parent: ContentView
    
    private var metalDevice: MTLDevice!
    private let metalCommandQueue: MTLCommandQueue!
    private let pipelineState: MTLRenderPipelineState
    
    init(parent: ContentView) {
        self.parent = parent
        if let newMetalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = newMetalDevice
        }
        
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let library = metalDevice.makeDefaultLibrary()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            self.pipelineState = try metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError()
        }
        
        self.board = Board(metalDevice: self.metalDevice)
        
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard
            let drawable = view.currentDrawable,
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            let commandBuffer = metalCommandQueue.makeCommandBuffer()
        else {
            return
        }
        
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setRenderPipelineState(pipelineState)
        
        board.draw(renderEncoder: renderEncoder)
        
        renderEncoder?.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
