//
//  ImmersiveView.swift
//  Floor
//
//  Created by Tim Mitra on 2023-12-16.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
  
  @State private var subscription: EventSubscription?
  @State private var sphereLeft: Entity?
  
  var body: some View {
    RealityView { content in
      
      // transparent floor
      let floor = ModelEntity(mesh: .generatePlane(width: 100, depth: 100), materials: [OcclusionMaterial()])
      floor.generateCollisionShapes(recursive: false)
      floor.components[PhysicsBodyComponent.self] = .init(
        massProperties: .default,
        mode: .static
      )
      content.add(floor)
      
      if let diceModel = try? await Entity(named: "Dice"),
         let dice = diceModel.children.first?.children.first {
        dice.scale = [0.1, 0.1, 0.1]
        dice.position.y = 0.5
        dice.position.z = -1.5
        dice.generateCollisionShapes(recursive: false)
        dice.components.set(InputTargetComponent())
        // add physics body
        dice.components[PhysicsBodyComponent.self] = .init(
          PhysicsBodyComponent(
            massProperties: .default,
            material: .generate(
              staticFriction: 0.8,
              dynamicFriction: 0.5,
              restitution: 0.1
            ),
            mode: .dynamic
          )
        )
        // if it's moving
        dice.components[PhysicsMotionComponent.self] = .init()
        
        content.add(dice)
      }
      
//      let wall = ModelEntity(mesh: .generatePlane(width: 50, depth: 50), materials: [OcclusionMaterial()])
//      wall.transform =  Transform(
//        pitch: 0,
//        yaw: 0,
//        roll: .pi/2
//      )
//      wall.generateCollisionShapes(recursive: false)
//      wall.components[PhysicsBodyComponent.self] = .init(
//        massProperties: .default,
//        mode: .static
//      )
//      content.add(wall)
//      
//      let wall2 = ModelEntity(mesh: .generatePlane(width: 50, depth: 50), materials: [OcclusionMaterial()])
//      wall2.transform =  Transform(
//        pitch: .pi/2,
//        yaw: 0,
//        roll: 0
//      )
//      wall2.generateCollisionShapes(recursive: false)
//      wall2.components[PhysicsBodyComponent.self] = .init(
//        massProperties: .default,
//        mode: .static
//      )
//      content.add(wall2)
//      
      
      
      // Add the initial RealityKit content
      if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
        content.add(immersiveContentEntity)
        
        sphereLeft = content.entities.first?.findEntity(named: "Sphere_Left")
        
        
        subscription = content.subscribe(
          to: CollisionEvents.Began.self,
          on: sphereLeft
        ) { collisionEvent in
          print(
            "💥 Collision between \(collisionEvent.entityA.name) and \(collisionEvent.entityB.name)"
          )
         }
        
        // Add an ImageBasedLight for the immersive content
        guard let resource = try? await EnvironmentResource(named: "ImageBasedLight") else { return }
        let iblComponent = ImageBasedLightComponent(source: .single(resource), intensityExponent: 0.25)
        immersiveContentEntity.components.set(iblComponent)
        immersiveContentEntity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: immersiveContentEntity))
//        
//        // Put skybox here.  See example in World project available at
//        // https://developer.apple.com/
      }
    }
    .gesture(
      DragGesture()
        .targetedToEntity(
          sphereLeft ?? Entity()
        )
        .onChanged({
          value in
          guard let sphereLeft,
                let parent = sphereLeft.parent else {
            return
          }
          sphereLeft.position = value.convert(
            value.location3D,
            from: .local,
            to: parent
          )
        })
        .onEnded({ value in
        })
    )
    .gesture(
      dragGesture
    )
    .gesture(tapGesture)
  }
  
  var dragGesture: some Gesture {
    DragGesture()
      .targetedToAnyEntity()
      .onChanged { value in
        value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
        value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic
        //value.entity.components[PhysicsMotionComponent.self]?.angularVelocity = [0,100,10000]
      }
//      .onEnded { value in
//        value.entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
//       // value.entity.components[PhysicsMotionComponent.self]?.linearVelocity = [0,0,10]
//        value.entity.components[PhysicsMotionComponent.self]?.angularVelocity = [0,0,10]
//      }
  }
  var tapGesture: some Gesture {
    TapGesture()
    .targetedToAnyEntity()
    .onEnded { value in
      value.entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
      value.entity.components[PhysicsMotionComponent.self]?.linearVelocity = [0,-15,-5]
    }
  }
}


#Preview {
  ImmersiveView()
    .previewLayout(.sizeThatFits)
}
