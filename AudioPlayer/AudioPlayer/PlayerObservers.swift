//
//  PlayerObservers.swift
//

import SwiftUI
import AVKit
import Combine

enum PlayerObservers {

    class Time {
        
        let publisher = PassthroughSubject<TimeInterval, Never>()
        private weak var player: AVPlayer?
        private var observer: Any?
        private var paused = false
        
        deinit {
            if let observer = observer {
                player?.removeTimeObserver(observer)
            }
        }
        
        init(player: AVPlayer) {
            self.player = player
            // Periodically observe the player's current time, whilst playing
            observer = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.2, preferredTimescale: 100), queue: nil) { [weak self] time in
                guard let self = self else {
                    return
                }
                if self.paused {
                    return
                }
                self.publisher.send(TimeInterval(CMTimeGetSeconds(player.currentTime())))
            }
        }
        
        func pause(_ pause: Bool) {
            paused = pause
        }
    }

    class CurrentItem {
        
        let publisher = PassthroughSubject<Bool, Never>()
        private var observer: NSKeyValueObservation?
        
        deinit {
            observer?.invalidate()
        }
        
        init(player: AVPlayer) {
            observer = player.observe(\.currentItem) { [weak self] player, change in
                guard let self = self else { return }
                self.publisher.send(player.currentItem != nil)
            }
        }
    }

    class Duration {
        
        let publisher = PassthroughSubject<TimeInterval, Never>()
        private var cancellable: AnyCancellable?
        
        init(player: AVPlayer) {
            let durationKeyPath: KeyPath<AVPlayer, CMTime?> = \.currentItem?.duration
            cancellable = player.publisher(for: durationKeyPath).sink { duration in
                guard let duration = duration else { return }
                guard duration.isNumeric else { return }
                self.publisher.send(duration.seconds)
            }
        }
        
        deinit {
            cancellable?.cancel()
        }
    }

    class Rate {
        
        let publisher = PassthroughSubject<Bool, Never>()
        private var observer: NSKeyValueObservation?
        
        deinit {
            observer?.invalidate()
        }
        
        init(player: AVPlayer) {
            observer = player.observe(\.rate) { [weak self] player, change in
                guard let self = self else { return }
                self.publisher.send(player.rate > 0.0)
            }
        }
    }

    class PlaybackCompleted {
        
        let publisher = PassthroughSubject<Void, Never>()
        private var cancellable: AnyCancellable?
        
        init() {
            cancellable = NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime).sink { notification in
                self.publisher.send()
            }
        }
        
        deinit {
            cancellable?.cancel()
        }
        
    }

}
