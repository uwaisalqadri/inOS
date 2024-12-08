//
//  BenchmarkView.swift
//  inOS
//
//  Created by Uwais Alqadri on 27/11/24.
//

import SwiftUI
import DeviceKit

enum Benchmark: CaseIterable {
  case cpu
  case storage
  case internet
  
  var icon: String {
    switch self {
    case .cpu:
      return "cpu"
    case .storage:
      return "internaldrive"
    case .internet:
      return "wifi"
    }
  }
  
  var title: String {
    switch self {
    case .cpu:
      return "CPU Usage"
    case .storage:
      return "Storage Speed"
    case .internet:
      return "Internet Speed"
    }
  }
  
  var value: String {
    switch self {
    case .cpu:
      return "65%"
    case .storage:
      return "89Mbps/65Mpbs"
    case .internet:
      return "16Mpbs"
    }
  }
}

struct BenchmarkView: View {
  
  @State private var benchmarks: [Benchmark] = Benchmark.allCases
  
  private var assessment: AssessmentTester {
    AssessmentTester(driver: .device)
  }
  
  var body: some View {
    VStack(spacing: 0) {
      ForEach(benchmarks, id: \.self) { benchmark in
        VStack {
          Image(systemName: benchmark.icon)
            .font(.system(size: 50))
            .foregroundColor(.blue)
          
          Text(benchmark.value)
            .font(.system(size: 24, weight: .bold))
            .padding(.top, 6)
          
          Text(benchmark.title)
            .font(.system(size: 16, weight: .medium))
        }
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 3)
        .padding()
        .background(
          Blur().cornerRadius(12)
        )
      }
      .padding([.top, .horizontal], 12)
    }
    .navigationBarTitleDisplayMode(.inline)
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
    }
  }
}

#Preview {
  NavigationView {
    BenchmarkView()
  }
}
