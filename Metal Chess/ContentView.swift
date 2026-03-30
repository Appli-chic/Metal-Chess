import SwiftUI
import MetalKit

struct ContentView: NSViewRepresentable {
    func makeCoordinator() -> Renderer {
        Renderer(parent: self)
    }
    
    func makeNSView(context: NSViewRepresentableContext<ContentView>) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 120
        mtkView.enableSetNeedsDisplay = true
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        
        return mtkView
    }
    
    func updateNSView(_ nsView: MTKView, context: NSViewRepresentableContext<ContentView>) {
        
    }
}

#Preview {
    Group {
        ContentView()
    }
}
