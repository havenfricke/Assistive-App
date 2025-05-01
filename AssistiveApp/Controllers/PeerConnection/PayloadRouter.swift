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
    var onReceiveAlertMessage: ((AlertMessage) -> Void)?
    var onReceiveNavigationRequest: ((NavigationHelpRequest) -> Void)?
    var onReceiveDirections: ((RoutePath) -> Void)?
    var onReceiveDrawPath: (([CGPoint]) -> Void)?
    var onReceivedOrder: ((Order) -> Void)?

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
            case .alertMessage:
                if let alert = try? payload.decode(as: AlertMessage.self){
                    onReceiveAlertMessage?(alert)
                }
            case .drawPath:
                if let points = try? payload.decode(as: [CGPoint].self){
                    onReceiveDrawPath?(points)
                }
            case .order:
                if let order = try? payload.decode(as: Order.self){
                    onReceivedOrder?(order)
                }
            case .navigationRequest:
                if let request = try? payload.decode(as: NavigationHelpRequest.self){
                    print("Navigation Help Request Received: \(request)")
                    onReceiveNavigationRequest?(request)
                    
                }
            }
        }
    }

enum PayloadType: String, Codable{
    case mobilityProfile
    case menuData
    case alertMessage
    case navigationRequest
    case drawPath
    case order
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
