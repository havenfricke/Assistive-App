//
//  ImageDecoderTest.swift
//  AssistiveApp
//
//  Created by Sean Perkins on 4/21/25.
//
import SwiftUI

struct ImageDecodeTestView: View {
    let base64String: String

    var body: some View {
        if let data = Data(base64Encoded: base64String),
           let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 300)
                .padding()
        } else {
            Text("❌ Failed to decode image from base64")
                .foregroundColor(.red)
        }
    }
}
