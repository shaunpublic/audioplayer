//
//  AudioPlayerApp.swift
//

import SwiftUI
import AVFoundation
import MediaPlayer

@main
struct AudioPlayerApp: App {
    
    static let sampleUrl = URL(string: "https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8")!
    var avPlayer = AVPlayer(url: sampleUrl)
    
    init() {
        ControlCenterHelper.shared.configure(for: avPlayer)
    }
    
    var body: some Scene {
        WindowGroup {
            PlayerView(player: avPlayer,
                       timeObserver: PlayerObservers.Time(player: avPlayer),
                       durationObserver: PlayerObservers.Duration(player: avPlayer),
                       rateObserver: PlayerObservers.Rate(player: avPlayer),
                       playbackCompletedObserver: PlayerObservers.PlaybackCompleted())
        }
    }
}
