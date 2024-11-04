//
//  DeviceAssessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 15/12/23.
//

import DeviceKit
import Foundation
import UIKit

public class DeviceAssessment: AssessmentDriver {
  private var processInfo = ProcessInfo.processInfo
  private var device = UIDevice.current
  
  public init() {}
  
  public var hasAssessmentPassed: [Assessment: Bool] {
    var results: [Assessment: Bool] = [:]
    
    if let assessment = assessments[.cpu] as? CPUInformation {
      results[.cpu] = assessment.model?.isEmpty != true
    } else {
      results[.cpu] = false
    }
    
    if let assessment = assessments[.storage] as? Storage {
      results[.storage] = assessment.totalRAM?.isEmpty == false && assessment.totalSpace?.isEmpty == false
    } else {
      results[.storage] = false
    }
    
    if let assessment = assessments[.jailbreak] as? Bool {
      results[.jailbreak] = !assessment
    } else {
      results[.jailbreak] = false
    }
    
    return results
  }
  
  public lazy var assessments: [Assessment: Any] = [
    .cpu: CPUInformation(
      model: Device.current.cpu.description,
      coreCount: processInfo.activeProcessorCount,
      architecture: "arm64",
      frequency: Device.current.cpu.frequency
    ),
    .jailbreak: isJailbroken
  ]
  
  public func startAssessment(for type: Assessment, completion: (() -> Void)?) {
    if type == .storage {
      measureStorageSpeed { writeSpeed, readSpeed in
        self.assessments[.storage] = Storage(
          readSpeed: "\(readSpeed) MB/s",
          writeSpeed: "\(writeSpeed) MB/s",
          remainingSpace: device.freeDiskSpaceInBytes.toGBFormat(),
          usedSpace: device.usedDiskSpaceInBytes.toGBFormat(),
          int32: UInt32(device.totalDiskSpaceInBytes.toGBFormat()),
          totalSpace: device.totalDiskSpaceInBytes.toGBFormat(),
          totalRAM: Int64(processInfo.physicalMemory).toGBFormat()
        )
        completion?()
      }
    }
  }
}

public extension DeviceAssessment {
  var isJailbroken: Bool {
  #if targetEnvironment(simulator)
    return false
  #else
    let fileManager = FileManager.default
    
    if fileManager.fileExists(atPath: "/bin/bash") ||
        fileManager.fileExists(atPath: "/usr/sbin/sshd") ||
        fileManager.fileExists(atPath: "/etc/apt") ||
        fileManager.fileExists(atPath: "/private/var/lib/apt/") ||
        fileManager.fileExists(atPath: "/Applications/Cydia.app") ||
        fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") {
      return true
    } else {
      return false
    }
  #endif
  }
  
  func measureStorageSpeed(completion: ((write: Double, speed: Double)) -> Void) {
    let fileManager = FileManager.default
    guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    
    let writeURL = documentsDirectory.appendingPathComponent("writeTestFile.dat")
    let writeData = Data(count: 1024 * 1024) // 1 MB of random data
    try? writeData.write(to: writeURL)
    
    // Measure write speed
    let writeStartTime = Date()
    do {
      try writeData.write(to: writeURL, options: .atomic)
    } catch {
      print("Error writing file: \(error)")
    }
    let writeEndTime = Date()
    let writeTime = writeEndTime.timeIntervalSince(writeStartTime)
    let writeSpeed = Double(writeData.count) / writeTime / 1024 / 1024 // MB/s
    
    // Measure read speed
    let readStartTime = Date()
    do {
      _ = try Data(contentsOf: writeURL)
    } catch {
      print("Error reading file: \(error)")
    }
    let readEndTime = Date()
    let readTime = readEndTime.timeIntervalSince(readStartTime)
    let readSpeed = Double(writeData.count) / readTime / 1024 / 1024 // MB/s
    
    // Clean up
    do {
      try fileManager.removeItem(at: writeURL)
      completion((writeSpeed, readSpeed))
    } catch {
      print("Error deleting file: \(error)")
    }
  }
}

extension UIDevice {
  var totalDiskSpaceInBytes: Int64 {
    guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
          let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
    
    return space
  }
  
  var totalDiskSpaceInt32: UInt32 {
    guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
          let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.uint32Value else { return 0 }
    
    return space
  }
  
  var freeDiskSpaceInBytes: Int64 {
    if #available(iOS 11.0, *) {
      if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [
        URLResourceKey.volumeAvailableCapacityForImportantUsageKey
      ]).volumeAvailableCapacityForImportantUsage {
        return space
      } else {
        return 0
      }
    } else {
      if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
         let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
        return freeSpace
      } else {
        return 0
      }
    }
  }
  
  var usedDiskSpaceInBytes: Int64 {
    return totalDiskSpaceInBytes - freeDiskSpaceInBytes
  }
}

extension Device.CPU {
  public var frequency: String {
    #if os(iOS) || os(tvOS)
    switch self {
    case .a4, .a5: return "800 MHz"
    case .a5X: return "1.0 GHz"
    case .a6: return "1.3 GHz"
    case .a6X: return "1.4 GHz"
    case .a7: return "1.3 GHz"
    case .a8: return "1.4 GHz"
    case .a8X: return "1.5 GHz"
    case .a9: return "1.85 GHz"
    case .a9X: return "2.16 GHz"
    case .a10Fusion, .a10XFusion: return "2.34 GHz"
    case .a11Bionic: return "2.39 GHz"
    case .a12Bionic, .a12XBionic, .a12ZBionic: return "2.49 GHz"
    case .a13Bionic: return "2.65 GHz"
    case .a14Bionic: return "2.99 GHz"
    case .a15Bionic: return "3.23 GHz"
    case .a16Bionic: return "3.46 GHz"
    case .a17Pro: return "3.78 GHz"
    case .a18: return "3.8 GHz" // Hypothetical value
    case .a18Pro: return "4.0 GHz" // Hypothetical value
    case .m1: return "Apple M1"
    case .m2: return "Apple M2"
    case .m3: return "Apple M3" // Placeholder for next-generation M3 chip
    case .m4: return "Apple M4" // Placeholder for next-generation M4 chip
    case .unknown: return "unknown"
    }
    #else
    return "N/A"
    #endif
  }
  
}
