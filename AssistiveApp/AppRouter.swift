//
//  AppRouter.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 4/17/25.
//

import SwiftUI

struct AppRouterView: View{
    @State private var isStaff: Bool = false
    
    var body: some View{
        VStack{
            Toggle("Staff Mode", isOn: $isStaff)
                .padding()
        Divider()
        }
            if isStaff{
                StaffView() // Replace with Kevin's Staff View when ready.
            } else {
                ContentView()
            }
        }
    }
