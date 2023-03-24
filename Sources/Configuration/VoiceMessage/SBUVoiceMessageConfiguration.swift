//
//  SBUVoiceMessageConfiguration.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2023/02/27.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import Foundation
import AVFoundation

public class SBUVoiceMessageConfiguration {
    /// To turn on the voice message feature, set as `true`
    public var isVoiceMessageEnabled: Bool = false
    var storedAudioSessionConfig: AudioSessionConfiguration?
    
    public var player = Player()
    
    public class Player { }
    
    public var recorder = Recorder()
    
    public class Recorder {
        let minRecordingTime: Double = 1000 // ms
        let maxRecordingTime: Double = 60000 // ms
        
        public var settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }
    
    struct AudioSessionConfiguration {
        let category: AVAudioSession.Category
        let categoryOptions: AVAudioSession.CategoryOptions
        let mode: AVAudioSession.Mode
    }
}
