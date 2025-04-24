//
//  PayloadRouter.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 4/22/25.
//
import Foundation
import CoreGraphics

class PayloadRouter
{
    static let shared = PayloadRouter()

    var onReceiveMobilityProfile: ((MobilityProfile) -> Void)?
    var onReceiveMenuData: ((MenuData) -> Void)?
    var onReceiveHelpRequest: (() -> Void)?
    var onReceiveDirections: ((RoutePath) -> Void)?
    var onReceiveDrawPath: (([CGPoint]) -> Void)?

    private init(){}
    
        func handle(payload: Payload){
            switch payload.type {
            case.mobilityProfile:
                if let profile = try? payload.decode(as: MobilityProfile.self){
                    onReceiveMobilityProfile?(profile)
                }
            case .menuData:
                if let menuData = try? payload.decode(as: MenuData.self){
                    onReceiveMenuData?(menuData)
                }
            case .helpRequest:
                onReceiveHelpRequest?()
            case .sendDirections:
                if let directions = try? payload.decode(as: RoutePath.self){
                    onReceiveDirections?(directions)
                }
            case .drawPath:
                if let points = try? payload.decode(as: [CGPoint].self){
                    onReceiveDrawPath?(points)
                }
                
            }
        }
    }

enum PayloadType: String, Codable{
    case mobilityProfile
    case menuData
    case helpRequest
    case sendDirections
    case drawPath
}

struct Payload: Codable {
    let type: PayloadType
    let data: Data // Encoded data of the message
    
    init<T: Codable>(type: PayloadType, model: T) throws {
        self.type = type
        self.data = try JSONEncoder().encode(model)
    }
    
    func decode<T: Codable>(as type: T.Type) throws -> T {
        return try JSONDecoder().decode(type, from: data)
    }
}
