//
//  DashboardStatusView.swift
//  inOS
//
//  Created by Uwais Alqadri on 27/10/24.
//

import SwiftUI

struct DashboardStatusView: View {
  var deviceStatuses: [FunctionalityPresenter.Status]
  @Binding var isSpecificationPresented: Bool
  
  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      ForEach(
        Array(deviceStatuses.enumerated()),
        id: \.offset
      ) { _, status in
        Button(action: {
          if status.isOther {
            isSpecificationPresented.toggle()
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
          .contentShape(.rect)
          .frame(width: 50, height: 30, alignment: .center)
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
      Blur().cornerRadius(12)
    )
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
    isSpecificationPresented: .constant(false)
  )
}
