//
//  DashboardMetricView.swift
//  inOS
//
//  Created by Uwais Alqadri on 27/10/24.
//

import SwiftUI
import Combine

struct DashboardMetricView: View {
  @Binding var deviceMetrics: [DeviceMetric]
  var isRunning: Bool
  @Binding var isSpecificationPresented: Bool
  @Binding var isBenchmarkPresented: Bool
  
  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      ForEach(
        Array(deviceMetrics.enumerated()),
        id: \.offset
      ) { _, status in
        Button(action: {
          guard status.isSettings else { return }
          if let url = URL(string: UIApplication.openSettingsURLString), #available(iOS 17.0, *) {
            UIApplication.shared.open(url)
          } else {
            isBenchmarkPresented.toggle()
          }
        }) {
          VStack(alignment: .center, spacing: 10) {
            Image(systemName: status.icon)
              .font(.system(size: 24))
              .foregroundColor(.blue)
              .frame(width: 10, height: 10)
            
            Text(status.value.replacingOccurrences(of: " ", with: ""))
              .font(.system(size: 11))
              .bold()
          }
          .frame(width: 50, height: 30, alignment: .center)
          .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
        
        if deviceMetrics.last != status {
          Spacer(minLength: 0)
        }
      }
    }
    .padding(.horizontal)
    .frame(maxWidth: .infinity, minHeight: 60, alignment: .center)
    .background(
      ZStack(alignment: .topLeading) {
        Image(systemName: "square.and.arrow.down.fill")
          .font(.system(size: 30))
          .padding(.leading, 20)
          .foregroundColor(.blue)
          .opacity(isRunning ? 0.0 : 1.0)
        Blur(style: .systemMaterial).cornerRadius(Theme.current.cornerRadius)
      }
    )
    .opacity(isRunning ? 0.2 : 1.0)
    .padding(.top, 20)
  }
}

#Preview {
  DashboardMetricView(
    deviceMetrics: .constant([
      .cpu("2.99HZ"),
      .memory("4GB"),
      .storage("64GB"),
      .battery("20%"),
      .settings("Settings"),
    ]),
    isRunning: false,
    isSpecificationPresented: .constant(false),
    isBenchmarkPresented: .constant(false)
  )
}
