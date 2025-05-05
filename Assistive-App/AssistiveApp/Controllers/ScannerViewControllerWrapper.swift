//
//  ScannerViewControllerWrapper.swift
//  AssistiveApp
//
//  Created by Haven F on 5/2/25.
//


import AVFoundation
import SwiftUI

struct ScannerViewControllerWrapper: UIViewControllerRepresentable {
    var onScan: (String) -> Void

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.onScan = onScan
        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}