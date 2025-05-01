//
//  LiveNavigationRequestView.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 4/30/25.
//
import SwiftUI

struct LiveNavigationRequestsView: View {
    @ObservedObject var navRequestManager: NavigationHelpRequestManager

    var body: some View {
        NavigationStack {
            List(navRequestManager.receivedRequests, id: \.targetName) { request in
                VStack(alignment: .leading) {
                    Text("Request: \(request.requestType.capitalized)")
                        .font(.headline)
                    Text("Target: \(request.targetName)")
                        .foregroundColor(.secondary)
                }
                .padding(8)
            }
            .navigationTitle("Live Requests")
        }
    }
}
