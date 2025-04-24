//
//  RoutePath.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 4/22/25.
//
import Foundation
import CoreGraphics

struct RoutePath: Codable {
    let points: [CGPoint]
    let destinationLabel: String?
}
