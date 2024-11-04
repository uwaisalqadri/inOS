//
//  SpecificationView.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 27/10/24.
//

import Foundation
import SwiftUI
import DeviceKit
import CoreMotion
import AVFoundation
import LocalAuthentication

struct SpecificationView: View {
  var models: [Model] {
    getDeviceModels()
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Information")
          .fontWeight(.bold)
          .frame(maxWidth: .infinity, alignment: .leading)
        Divider()
        Text("Specification")
          .fontWeight(.bold)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.leading, 10)
      }
      .padding(.horizontal, 16)
      .background(Color.gray.opacity(0.1))
      .clipShape(RoundedRectangle(cornerRadius: 14))
      .frame(height: 50)
      .padding(.horizontal, 16)
      
      List(models) { model in
        HStack {
          Text(model.title)
            .frame(maxWidth: .infinity, alignment: .leading)
          Text(model.value)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 10)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
      }
      .listStyle(.plain)
    }
    .padding(.top, 16)
    .toolbar {
      ToolbarItem(placement: .principal) {
        HStack(spacing: 4) {
          Image(systemName: FunctionalityPresenter.Status.Specs.phone.icon)
            .font(.system(size: 20))
            .foregroundColor(.blue)
          Text(Device.current.safeDescription)
            .font(.system(size: 14, weight: .semibold))
        }
      }
      
      ToolbarItem(placement: .topBarTrailing) {
        Button(action: {
          if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
          }
        }) {
          Image(systemName: "gear")
            .font(.system(size: 20))
            .foregroundColor(.blue)
        }
      }
    }
  }
}

extension SpecificationView {
  struct Model: Identifiable {
    let id = UUID()
    let title: String
    let value: String
  }
  
  func getDeviceModels() -> [Model] {
    let screenSize = UIScreen.main.bounds.size
    let displayType = UIScreen.main.traitCollection.displayGamut == .P3 ? "OLED" : "LCD"
    let resolution = "\(UIScreen.main.nativeBounds.size.width.int) x \(UIScreen.main.nativeBounds.size.height.int) @ \(UIScreen.main.scale.int) PPI"
    
    return [
      .init(title: "Model", value: "\(UIDevice.current.model) (\(getDeviceIdentifier()))"),
      .init(title: "Model number", value: "\(modelIdentifier())"),
      .init(title: "Size", value: "\(formatScreenSize(screenSize))"),
      .init(title: "iOS Ver.", value: UIDevice.current.systemVersion),
      .init(title: "Display", value: displayType),
      .init(title: "Screen size", value: "\(screenSize.width.int) x \(screenSize.height.int)"),
      .init(title: "Resolution", value: resolution),
      .init(title: "Multitouch", value: "Supported"),
      .init(title: "3D Touch", value: check3DTouchSupport()),
      .init(title: "Face ID", value: "\(hasFaceID() ? "Supported" : "Not Supported")"),
      .init(title: "Touch ID", value: "\(hasTouchID() ? "Supported" : "Not Supported")"),
      .init(title: "Accelerometer", value: checkSensorAvailability(.accelerometer)),
      .init(title: "Gyroscope", value: checkSensorAvailability(.gyroscope)),
      .init(title: "Proximity Sensor", value: "Supported"),
      .init(title: "Light Sensor", value: "Supported"),
      .init(title: "Magnetometer", value: checkSensorAvailability(.magnetometer)),
      .init(title: "Barometer", value: "\(CMAltimeter.isRelativeAltitudeAvailable() ? "Supported" : "Not Supported")")
    ]
  }
  
  // MARK: - Helper Methods
  
  func hasFaceID() -> Bool {
      return AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front) != nil
  }
  
  func hasTouchID() -> Bool {
    return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
  }
  
  private func getDeviceIdentifier() -> String {
    return String(UIDevice.current.identifierForVendor?.uuidString.prefix(5) ?? "-")
  }
  
  private func formatScreenSize(_ size: CGSize) -> String {
    return "\(size.width.int) x \(size.height.int) mm"
  }
  
  private func check3DTouchSupport() -> String {
    return UIScreen.main.traitCollection.forceTouchCapability == .available ? "Supported" : "Not supported"
  }
  
  enum SensorType {
    case accelerometer, gyroscope, magnetometer
  }
  
  private func checkSensorAvailability(_ type: SensorType) -> String {
    let motionManager = CMMotionManager()
    
    switch type {
    case .accelerometer:
      return motionManager.isAccelerometerAvailable ? "Supported" : "Not Supported"
    case .gyroscope:
      return motionManager.isGyroAvailable ? "Supported" : "Not Supported"
    case .magnetometer:
      return motionManager.isMagnetometerAvailable ? "Supported" : "Not Supported"
    }
  }
  
  func modelIdentifier() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    return withUnsafePointer(to: &systemInfo.machine) {
      $0.withMemoryRebound(to: CChar.self, capacity: 1) {
        String(validatingUTF8: $0) ?? "Unknown"
      }
    }
  }
}

extension CGFloat {
  var int: Int {
    Int(self)
  }
}
