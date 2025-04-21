//
//  MobilityProfile.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 4/19/25.
//

import Foundation
import SwiftData

// MARK: - Mobility Profile Model
@Model
final class MobilityProfile {
    var id:UUID
    var name: String
    var profileImage: Data?
    var wheelchairUser:Bool
    var maxTravelDistanceMeters:Double
    var reachLevel: ReachLevel
    var requiresAssistance: Bool
    var allergens: [String]
    var notes: String?
    var lastUpdated: Date
    
    init(
        id: UUID = UUID(),
        name: String = "",
        profileImage: Data? = nil,
        wheelchairUser: Bool = false,
        maxTravelDistanceMeters: Double = 15.0,
        reachLevel: ReachLevel = .moderate,
        requiresAssistance: Bool = false,
        allergens: [String] = [],
        notes: String? = nil,
        lastUpdated: Date = Date()
    )
    {
        self.id = id
        self.name = name
        self.profileImage = profileImage
        self.wheelchairUser = wheelchairUser
        self.maxTravelDistanceMeters = maxTravelDistanceMeters
        self.reachLevel = reachLevel
        self.requiresAssistance = requiresAssistance
        self.allergens = allergens
        self.notes = notes
        self.lastUpdated = lastUpdated
    }
}

// MARK: -Codable Conformance
extension MobilityProfile: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case profileImage
        case wheelchairUser
        case maxTravelDistanceMeters
        case reachLevel
        case requiresAssistance
        case allergens
        case notes
        case lastUpdated
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try container.decode(UUID.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let profileImage = try container.decodeIfPresent(Data.self, forKey: .profileImage) ?? nil
        let wheelchairUser = try container.decode(Bool.self, forKey: .wheelchairUser)
        let maxTravelDistanceMeters = try container.decode(Double.self, forKey: .maxTravelDistanceMeters)
        let reachLevel = try container.decode(ReachLevel.self, forKey: .reachLevel)
        let requiresAssistance = try container.decode(Bool.self, forKey: .requiresAssistance)
        let allergens = try container.decode([String].self, forKey: .allergens)
        let notes = try container.decodeIfPresent(String.self, forKey: .notes)
        let lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
        
        self.init(
            id: id,
            name: name,
            profileImage: profileImage,
            wheelchairUser: wheelchairUser,
            maxTravelDistanceMeters: maxTravelDistanceMeters,
            reachLevel: reachLevel,
            requiresAssistance: requiresAssistance,
            allergens: allergens,
            notes: notes,
            lastUpdated: lastUpdated
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(profileImage, forKey: .profileImage)
        try container.encode(wheelchairUser, forKey: .wheelchairUser)
        try container.encode(maxTravelDistanceMeters, forKey: .maxTravelDistanceMeters)
        try container.encode(reachLevel, forKey: .reachLevel)
        try container.encode(requiresAssistance, forKey: .requiresAssistance)
        try container.encode(allergens, forKey: .allergens)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(lastUpdated, forKey: .lastUpdated)
    }
}
// MARK: - JSON Export Helpers
extension MobilityProfile {
    func toJSON() -> Data?{
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(self)
    }
    
    static func fromJSON(_ data: Data) -> MobilityProfile? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(MobilityProfile.self, from: data)
    }
    
    func toJSONString(pretty: Bool = false) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = pretty ? . prettyPrinted : []
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data:data, encoding:.utf8)
    }
}

//MARK: - Reach Level Enum
enum ReachLevel: String, Codable, CaseIterable {
    case none = "No Reach"
    case limited = "Less than 1 foot"
    case moderate = "Up to 2 feet"
    case extended = "Up to 1 meter"

    var approxDistanceMeters: Double {
        switch self {
        case .none: return 0.0
        case .limited: return 0.3
        case .moderate: return 0.6
        case .extended: return 1.0
        }
    }
}
