//
//  MaintenanceView.swift
//  inOS
//
//  Created by Uwais Alqadri on 27/11/24.
//

import SwiftUI

struct MaintenanceView: View {
  @StateObject private var presenter: MaintenancePresenter
  
  init(type: MaintenanceView.PageType) {
    _presenter = StateObject(
      wrappedValue: MaintenancePresenter(type)
    )
  }
    
  var body: some View {
    VStack(alignment: .center, spacing: 10) {
      Divider()
        .padding(.vertical, 10)
      
      if let icon = Bundle.main.icon {
        Image(uiImage: icon)
          .resizable()
          .frame(width: 70, height: 70)
          .clipShape(.rect(cornerRadius: 15))
          .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 6)
          .padding(.bottom, 10)
          .padding(.top, 30)
      }
      
      Text(presenter.state.type.title)
        .font(.title2)
        .fontWeight(.semibold)
        .multilineTextAlignment(.center)
      
      Text(presenter.state.type.desc)
        .font(.body)
        .multilineTextAlignment(.center)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
        .padding(20)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(16)
      
      Divider()
        .padding(.vertical, 10)
      
      if presenter.state.type == .forceUpdate {
        PrimaryButton(title: "Update") {
          
        }
      }
    }
    .padding()
  }
}

extension MaintenanceView {
  enum PageType {
    case maintenance
    case forceUpdate
    case secured
    
    var title: String {
      switch self {
      case .maintenance:
        "Maintenance"
      case .forceUpdate:
        "Force Update"
      case .secured:
        "Secured"
      }
    }
    
    var desc: String {
      switch self {
      case .maintenance:
        "We are currently performing scheduled maintenance. Please try again later.\n\nSorry for the inconvenience."
      case .forceUpdate:
        "A new version of the app is available. Please update to continue using the app."
      case .secured:
             "We've detected potential security risks on your device. To ensure your data's safety, access to the app has been restricted.\n\nPlease use a secure environment to continue."
      }
    }
  }
}

#Preview {
  MaintenanceView(type: .forceUpdate)
}

#Preview {
  MaintenanceView(type: .maintenance)
}

#Preview {
  MaintenanceView(type: .secured)
}
