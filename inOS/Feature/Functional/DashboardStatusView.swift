//
//  DashboardStatusView.swift
//  inOS
//
//  Created by Uwais Alqadri on 27/10/24.
//

import SwiftUI

struct DashboardStatusView: View {
  var deviceStatuses: [FunctionalityPresenter.Status]
  var isTesting: Bool
  @Binding var isSpecificationPresented: Bool
  @Binding var isBenchmarkPresented: Bool
  
  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      ForEach(
        Array(deviceStatuses.enumerated()),
        id: \.offset
      ) { _, status in
        Button(action: {
          if status.isOther {
            isBenchmarkPresented.toggle()
          } else if let url = URL(string: UIApplication.openSettingsURLString), status.isSettings {
            UIApplication.shared.open(url)
          }
        }) {
          VStack(alignment: .center, spacing: 10) {
            Image(systemName: status.spec.icon)
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
        
        if deviceStatuses.last != status {
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
          .opacity(isTesting ? 0.0 : 1.0)
        Blur(style: .systemMaterial).cornerRadius(Theme.current.cornerRadius)
      }
    )
    .opacity(isTesting ? 0.2 : 1.0)
    .padding(.top, 20)
  }
}

#Preview {
  DashboardStatusView(
    deviceStatuses: [
      .init(.cpu, value: "2.99HZ"),
      .init(.memory, value: "4GB"),
      .init(.storage, value: "64GB"),
      .init(.battery, value: "20%"),
      .init(.other, value: "Specs"),
    ],
    isTesting: false,
    isSpecificationPresented: .constant(false),
    isBenchmarkPresented: .constant(false)
  )
}
