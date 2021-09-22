### How to make a custom [SCNGeometry](https://developer.apple.com/documentation/scenekit/scngeometry)?

This is a demo playground for this [Stack Overflow question](https://stackoverflow.com/q/69240185/14351818).

---

According to the [documentation](https://developer.apple.com/documentation/scenekit/scngeometrysource), making a custom geometry takes 3 steps.

1. Create a `SCNGeometrySource` that contains the 3D shape's vertices.
2. Create a `SCNGeometryElement` that contains an array of indices, showing how the vertices connect.
3. Combine the `SCNGeometrySource` source and `SCNGeometryElement` into a `SCNGeometry`.

**Let's start from step 1.** You want your custom geometry to be a 3D shape, right? You only have 2 vertices, though.

```
let vertices: [Vertex] = [         /// what's `r`, `g`, `b` for btw? 
    Vertex(x: 0.0, y: 0.0, z: 0.0, r: 1.0, g: 0.0, b: 0.0),
    Vertex(x: 1.0, y: 0.0, z: 0.0, r: 0.0, g: 0.0, b: 1.0)
]
```

This will form a line...

[![Line from (0, 0, 0) to (1, 0, 0). Format: (X, Y, Z)][1]][1]


A common way of making 3D shapes is from triangles. Let's add 2 more vertices to make a pyramid.

```
let vertices: [Vertex] = [
    Vertex(x: 0.0, y: 0.0, z: 0.0, r: 1.0, g: 0.0, b: 0.0), /// vertex 0
    Vertex(x: 1.0, y: 0.0, z: 0.0, r: 0.0, g: 0.0, b: 1.0), /// vertex 1
    Vertex(x: 1.0, y: 0.0, z: -0.5, r: 0.0, g: 0.0, b: 1.0), /// vertex 2
    Vertex(x: 0.0, y: 1.0, z: 0.0, r: 0.0, g: 0.0, b: 1.0), /// vertex 3
]
```

[![Pyramid from (0, 0, 0) to (1, 0, 0) to (1, 0, -0.5) to (0, 1, 0)][2]][2]

Now, we need to connect the vertices into something that SceneKit can handle. In your current code, you convert `vertices` into `Data`, then use the [`init(data:semantic:vectorCount:usesFloatComponents:componentsPerVector:bytesPerComponent:dataOffset:dataStride:)`](https://developer.apple.com/documentation/scenekit/scngeometrysource/1523320-init) initializer.

```
let vertexData = Data(
    bytes: vertices,
    count: MemoryLayout<Vertex>.size * vertices.count
)
let positionSource = SCNGeometrySource(
    data: vertexData,
    semantic: SCNGeometrySource.Semantic.vertex,
    vectorCount: vertices.count,
    usesFloatComponents: true,
    componentsPerVector: 3,
    bytesPerComponent: MemoryLayout<Float>.size,
    dataOffset: 0,
    dataStride: MemoryLayout<Vertex>.size
)
```

This is very advanced and complicated. It's way easier with [`init(vertices:)`](https://developer.apple.com/documentation/scenekit/scngeometrysource/2034708-init).

```
let verticesConverted = vertices.map { SCNVector3($0.x, $0.y, $0.z) } /// convert to `[SCNVector3]`
let positionSource = SCNGeometrySource(vertices: verticesConverted)
```

Now that you've got the `SCNGeometrySource`, it's **time for step 2** — connecting the vertices via `SCNGeometryElement`. In your current code, you use [`init(data:primitiveType:primitiveCount:bytesPerIndex:)`](https://developer.apple.com/documentation/scenekit/scngeometryelement/1522615-init), then pass in `nil`...

```
let elements = SCNGeometryElement(
    data: nil,
    primitiveType: .point,
    primitiveCount: vertices.count,
    bytesPerIndex: MemoryLayout<Int>.size
)
```


If the data itself is `nil`, how will SceneKit know how to connect your vertices? But anyway, there's once again an easier initializer: [`init(indices:primitiveType:)`](https://developer.apple.com/documentation/scenekit/scngeometryelement/1523191-init). This takes in an array of [`FixedWidthInteger`](https://developer.apple.com/documentation/swift/fixedwidthinteger), each representing a ​vertex back in your `positionSource`.

So how is each vertex represented by a `FixedWidthInteger`? Well, remember how you passed in `verticesConverted`, an array of `SCNVector3`, to `positionSource`? SceneKit sees each `FixedWidthInteger` as an index and uses it access `verticesConverted`.


Since indices are always integers and positive, [`UInt16`](https://developer.apple.com/documentation/swift/uint16) should do fine (it conforms to `FixedWidthInteger`).

```
/// pairs of 3 indices, each representing a vertex
let indices: [UInt16] = [
   ​0, 1, 3, /// front triangle
   ​1, 2, 3, /// right triangle
   ​2, 0, 3, /// back triangle
   ​3, 0, 2, /// left triangle
   ​0, 2, 1 /// bottom triangle
]
let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
```

The order here is very specific. By default, SceneKit only renders the front face of triangles, and in order to distinguish between the front and back, it relies on your ordering. The basic rule is: **counterclockwise** means front.

[![Front triangle highlighted. Vertices are 0, 1, and 3, counterclockwise][3]][3]

So to refer to the first triangle, you could say:

- ​0, 1, 3
- 1, 3, 0
- 3, 0, 1

All are fine. Finally, **step 3** is super simple. Just combine the `SCNGeometrySource` and `SCNGeometryElement`.

```
let geometry = SCNGeometry(sources: [positionSource], elements: [element])
```

And that's it! Now that both your `SCNGeometrySource` and `SCNGeometryElement` are set up correctly, `lightingModel` will work properly.

```
/// add some color
let material = SCNMaterial()
material.diffuse.contents = UIColor.orange
material.lightingModel = .physicallyBased
geometry.materials = [material]

/// add the node
let node = SCNNode(geometry: geometry)
scene.rootNode.addChildNode(node)
```


[![Orange pyramid][4]][4]


---

**Notes:**

- I noticed that you were trying to use 2 `SCNGeometrySource`s. The second one was to add color with `SCNGeometrySource.Semantic.color`, right? The simpler initializer that I used, [`init(vertices:)`](https://developer.apple.com/documentation/scenekit/scngeometrysource/2034708-init), defaults to [`.vertex`](https://developer.apple.com/documentation/scenekit/scngeometrysource/semantic/1522639-vertex). If you want per-vertex color or something, you'll probably need to go back to [`init(data:semantic:vectorCount:usesFloatComponents:componentsPerVector:bytesPerComponent:dataOffset:dataStride:)`](https://developer.apple.com/documentation/scenekit/scngeometrysource/1523320-init).
- Try `sceneView.autoenablesDefaultLighting = true` for some better lighting



  [1]: https://i.stack.imgur.com/IDCKi.png
  [2]: https://i.stack.imgur.com/xg1Eb.png
  [3]: https://i.stack.imgur.com/27lsy.png
  [4]: https://i.stack.imgur.com/y3lv0.png

