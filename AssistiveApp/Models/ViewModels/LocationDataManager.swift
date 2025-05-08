//
//  LocationDataManager.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 5/7/25.
//

import Foundation
import SwiftUI

@MainActor
class LocationDataManager: ObservableObject {
    @Published var menuData: MenuData? = nil
    @Published var navData: NavigationDataPayload? = nil

    init() {
        PayloadRouter.shared.onReceiveMenuData = { [weak self] data in
            Task { @MainActor in
                print("📥 MenuData received")
                self?.menuData = data
            }
        }

        PayloadRouter.shared.onReceivedNavigationData = { [weak self] nav in
            Task { @MainActor in
                print("📥 NavigationData received")
                self?.navData = nav
            }
        }
    }
}
