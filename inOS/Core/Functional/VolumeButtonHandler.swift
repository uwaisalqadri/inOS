//
//  VolumeButtonHandler.swift
//  Data
//
//  Created by Uwais Alqadri on 25/1/24.
//

import AVFoundation
import Foundation

class VolumeButtonHandler: NSObject {
  static var shared = VolumeButtonHandler()
  
  private var audioLevel: Float = 0.0
  
  var outputVolumeObservation: NSKeyValueObservation?
  var volumeUpHandler: (() -> Void)?
  var volumeDownHandler: (() -> Void)?
  
  init(volumeUpHandler: (() -> Void)? = nil, volumeDownHandler: (() -> Void)? = nil) {
    super.init()
    self.volumeUpHandler = volumeUpHandler
    self.volumeDownHandler = volumeDownHandler
    listenVolumeButton()
  }
  
  func listenVolumeButton() {
    let audioSession = AVAudioSession.sharedInstance()
    try? audioSession.setCategory(.playback, mode: .default, options: [])
    do {
      try audioSession.setActive(true, options: [])
      outputVolumeObservation = audioSession.observe(\.outputVolume) { [weak self] audioSession, _ in
        guard let self else { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        let currentVolume = audioSession.outputVolume
        if currentVolume > audioLevel {
          volumeUpHandler?()
        } else if currentVolume < audioLevel {
          volumeDownHandler?()
        }
        audioLevel = currentVolume
        print(currentVolume)
      }
      audioLevel = audioSession.outputVolume
    } catch {
      print("Error")
    }
  }
}
