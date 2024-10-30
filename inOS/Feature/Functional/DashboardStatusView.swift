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
    HStack(spacing: 0) {
      ForEach(
        Array(deviceStatuses.enumerated()),
        id: \.offset
      ) { _, status in
        Button(action: {
          if status.isOther {
            isSpecificationPresented.toggle()
          }
        }) {
          VStack(spacing: 4) {
            Image(systemName: status.spec.icon)
              .font(.system(size: 24))
              .foregroundColor(.blue)
            Text(status.value.replacingOccurrences(of: " ", with: ""))
              .font(.system(size: 12))
              .bold()
          }
        }
        .buttonStyle(.plain)
        .background(
          NavigationLink(
            destination: SpecificationView(),
            isActive: $isSpecificationPresented
          ) {
            EmptyView()
          }
        )
        
        if deviceStatuses.last != status {
          Spacer(minLength: 0)
        }
      }
    }
    .padding(.horizontal)
    .frame(height: 60)
    .background(
      Blur().cornerRadius(12)
    )
  }
}
