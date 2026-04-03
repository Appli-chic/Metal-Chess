import MetalKit

class Piece {
    private let margin = TILE_SIZE / 6
    private let color: vector_float4
    private let x: Int
    private let y: Int
    
    init(x: Int, y: Int, color: vector_float4) {
        self.x = x
        self.y = y
        self.color = color
    }
    
    func draw(metalDevice: MTLDevice, renderEncoder: MTLRenderCommandEncoder?) {
        var vertices: [Vertex] = []
        
        let positionX = -1 + (TILE_SIZE * Float(x))
        let positionY = -1 + (TILE_SIZE * Float(y))
        
        let bottomLeftVertex = Vertex(position: [positionX + margin, positionY + margin], color: color)
        let bottomRightVertex = Vertex(position: [positionX + TILE_SIZE - margin, positionY + margin], color: color)
        let topRightVertex = Vertex(position: [positionX + TILE_SIZE - margin, positionY + TILE_SIZE - margin], color: color)
        let topLeftVertex = Vertex(position: [positionX + margin, positionY + TILE_SIZE - margin], color: color)
        
        vertices.append(contentsOf: [
            topLeftVertex,
            topRightVertex,
            bottomRightVertex,
            
            topLeftVertex,
            bottomLeftVertex,
            bottomRightVertex,
        ])
        
        let vertexBuffer = metalDevice.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<Vertex>.stride,
            options: .storageModeShared,
        )!
        
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }
}
