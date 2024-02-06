//
//  AudioManager.swift
//  AutoStop WatchKit Extension
//
//  Created by Mario Kohlhoff on 11.11.21.
//

import Foundation
import AVFoundation

class AudioManager {
    func stopAudio() -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            return true
        } catch {
            Logger.shared.error("Could not stop audio: \(error.localizedDescription)")
            return false
            
        }
    }
}
