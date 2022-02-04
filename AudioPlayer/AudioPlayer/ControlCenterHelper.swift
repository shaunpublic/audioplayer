//
//  ControlCenterHelper.swift
//

import MediaPlayer

class ControlCenterHelper {
    
    static let shared = ControlCenterHelper()
    private var rateObserver: Any?
    private var playbackTimeObserver: Any?
    
    func configure(for player: AVPlayer) {
        configureAudioSession()
        configureCommandCenterTargets(player: player)
        configureNowPlayingInfo(player: player)
        
        // Update MPNowPlayingInfoCenter's display whenever playback starts/stops.
        rateObserver = player.observe(\.rate) { [weak self] player, change in
            guard let self = self else {
                return
            }
            self.updateNowPlayingInfo(player: player)
        }
        
        // Update MPNowPlayingInfoCenter's display playback time periodically.
        playbackTimeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.2, preferredTimescale: 100), queue: nil) { [weak self] time in
            guard let self = self else {
                return
            }
            // The playback time shouldn't be changing if the playback rate is 0, so we don't need to repeatedly update playback info here.
            if player.rate > 0 {
                self.updateNowPlayingInfo(player: player)
            }
        }
    }
    
    private func configureAudioSession() {
        
        // Ensure the correct AVAudioSession configuration is in place,
        // to allow the execution of background audio playback and synchronisation
        // with MPNowPlayingInfoCenter (Control Center).
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.mode == .default, audioSession.category == .playback {
            return
        }
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
        } catch {
            print("AVAudioSession setCategory error: \(error.localizedDescription)")
        }
        do {
            try audioSession.setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
        } catch {
            print("AVAudioSession setActive error: \(error.localizedDescription)")
        }
    }
    
    private func configureCommandCenterTargets(player: AVPlayer) {
        
        // Respond to remote commands to play and pause playback.
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { event in
            if player.rate == 0 {
                player.play()
                return .success
            }
            return .commandFailed
        }
        commandCenter.pauseCommand.addTarget { event in
            if player.rate > 0 {
                player.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    private func configureNowPlayingInfo(player: AVPlayer) {
        
        // In this initial configuration of MPNowPlayingInfoCenter,
        // an image is supplied, a well as population of some media properties.
        var info: [String : Any] = [:]
        info[MPMediaItemPropertyTitle] = "Test Track"
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = TimeInterval(CMTimeGetSeconds(player.currentTime()))
        info[MPMediaItemPropertyPlaybackDuration] = TimeInterval(CMTimeGetSeconds((player.currentItem?.duration) ?? CMTime.zero))
        info[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        if let image = UIImage(named: "ControlCenterImage.jpg") {
          info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
            return image
          }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    func updateNowPlayingInfo(player: AVPlayer) {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else {
            return
        }
        
        // When subsequent updates to MPNowPlayingInfoCenter occur,
        // only a subset of media properties would require new updates.
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = TimeInterval(CMTimeGetSeconds(player.currentTime()))
        info[MPMediaItemPropertyPlaybackDuration] = TimeInterval(CMTimeGetSeconds((player.currentItem?.duration) ?? CMTime.zero))
        info[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
}
