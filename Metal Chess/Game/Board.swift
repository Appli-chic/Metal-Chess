import MetalKit

private let BOARD_SIZE = 8

class Board {
    private let vertexBuffer: MTLBuffer
    private var vertexSize: Int = 0
    
    init(metalDevice: MTLDevice) {
        let black: vector_float4 = [0, 0, 0, 1]
        let white: vector_float4 = [1, 1, 1, 1]
        let tileSize: Float = 2 / Float(BOARD_SIZE)
        var vertices: [Vertex] = []
        
        for y in 0..<BOARD_SIZE {
            for x in 0..<BOARD_SIZE {
                let color: vector_float4 = if (x + y) % 2 == 0 {
                    black
                } else {
                    white
                }
                
                let positionX = -1 + (tileSize * Float(x))
                let positionY = -1 + (tileSize * Float(y))
                
                let bottomLeftVertex = Vertex(position: [positionX, positionY], color: color)
                let bottomRightVertex = Vertex(position: [positionX + tileSize, positionY], color: color)
                let topRightVertex = Vertex(position: [positionX + tileSize, positionY + tileSize], color: color)
                let topLeftVertex = Vertex(position: [positionX, positionY + tileSize], color: color)
                
                self.vertexSize += 6;
                vertices.append(contentsOf: [
                    topLeftVertex,
                    topRightVertex,
                    bottomRightVertex,
                    
                    topLeftVertex,
                    bottomLeftVertex,
                    bottomRightVertex,
                ])
            }
        }
        
        self.vertexBuffer = metalDevice.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<Vertex>.stride,
            options: [],
        )!
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder?) {
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: self.vertexSize)
    }
}
