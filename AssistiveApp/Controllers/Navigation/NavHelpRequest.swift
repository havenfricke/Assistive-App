//
//  NavHelpRequest.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 5/1/25.
//


enum NavigationRequestType: String, CaseIterable, Identifiable{
    case table
    case restroom
    case customerStation
    
    var id: String { rawValue }
    
    var label:String {
        switch self{
        case .table: return "Display Table Location"
        case .restroom: return "Display Restroom Location"
        case .customerStation: return "Customer Station"
        }
    }
    var systemImage: String{
        switch self{
        case .table: return "chair"
        case .restroom: return "figure.walk"
        case .customerStation: return "wrench"
        }
    }
    var categoryMatch: LocationCategory{
        switch self{
        case .table: return .table
        case .restroom: return .restroom
        case .customerStation: return .customerStation
        }
    }
}

struct NavigationHelpRequest: Codable{
    let requestType: String
    let targetName: String
}

