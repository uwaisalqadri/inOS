//
//  LiveActivityManager.swift
//  inOS
//
//  Created by Uwais Alqadri on 30/03/25.
//

import ActivityKit
import SwiftUI

public struct InOSWidgetAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    var benchmark: String
  }
  public var name: String
}

@available(iOS 16.2, *)
public struct LiveActivityManager {
  public static func startLiveActivity(with benchmark: String) {
    let attributes = InOSWidgetAttributes(name: benchmark)
    let state = InOSWidgetAttributes.ContentState(benchmark: benchmark)
    let content = ActivityContent(state: state, staleDate: nil)
    
    Task {
      do {
        let _ = try Activity<InOSWidgetAttributes>.request(
          attributes: attributes,
          content: content,
          pushType: nil
        )
      } catch {
        print("Failed to start Live Activity: \(error)")
      }
    }
  }
  
  public static func updateLiveActivity(with benchmark: String) {
    guard LiveActivityManager.isLiveActivityActive() else { return }
    
    Task {
      let state = InOSWidgetAttributes.ContentState(benchmark: benchmark)
      let content = ActivityContent(state: state, staleDate: nil)
      
      for activity in Activity<InOSWidgetAttributes>.activities {
        await activity.update(content)
        print("Live Activity updated!")
      }
    }
  }
  
  public static func endLiveActivity(with benchmark: String) {
    let state = InOSWidgetAttributes.ContentState(benchmark: benchmark)
    let content = ActivityContent(state: state, staleDate: nil)
    
    Task {
      for activity in Activity<InOSWidgetAttributes>.activities {
        await activity.end(content, dismissalPolicy: .immediate)
        print("Live Activity ended!")
      }
    }
  }
  
  public static func isLiveActivityActive() -> Bool {
    for activity in Activity<InOSWidgetAttributes>.activities {
      if !activity.id.isEmpty {
        return true
      }
    }
    return false
  }
}
