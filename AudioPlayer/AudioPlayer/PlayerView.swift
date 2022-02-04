//
//  AudioView.swift
//

import SwiftUI
import AVKit

struct PlayerView: View {
    
    let player: AVPlayer
    let timeObserver: PlayerObservers.Time
    let durationObserver: PlayerObservers.Duration
    let rateObserver: PlayerObservers.Rate
    let playbackCompletedObserver: PlayerObservers.PlaybackCompleted
    
    @State private var currentTime: TimeInterval = 0
    @State private var currentDuration: TimeInterval = 0
    @State private var isPlaying = false
    
    var body: some View {
        VStack {
            
            // Some text
            Text("Hey everybody - it's audio!").font(.headline).italic()
            
            // Progress & seek bar
            let minValueLabel = Text("\(formatted(timeSeconds: currentTime))").font(.footnote)
            let maxValueLabel = Text("\(formatted(timeSeconds: currentDuration))").font(.footnote)
            Slider(value: $currentTime, in: 0...currentDuration, onEditingChanged: sliderEditingChanged,
                   minimumValueLabel: minValueLabel, maximumValueLabel: maxValueLabel) {
            }.tint(Color.black)
                .disabled(!isPlaying).padding(.vertical, 20.0)
            
            // Conditional play/pause buttons, using custom button: AudioPlayerButton
            if isPlaying {
                AudioPlayerButton(systemName: "pause.circle.fill", action: player.pause)
            } else {
                AudioPlayerButton(systemName: "play.circle.fill", action: player.play)
            }
            
        }.padding()
        
        // Observe and response to various properties & events of the AVPlayer
        .onReceive(timeObserver.publisher) { time in
            self.currentTime = time
        }
        .onReceive(durationObserver.publisher) { duration in
            self.currentDuration = duration
        }
        .onReceive(rateObserver.publisher) { isPlaying in
            self.isPlaying = isPlaying
        }
        .onReceive(playbackCompletedObserver.publisher) {
            self.player.seek(to: CMTime.zero)
        }
        .onDisappear {
            self.player.replaceCurrentItem(with: nil)
        }
    }
    
    private func sliderEditingChanged(editing: Bool) {
        // If the Slider value is being edited, pause the observer.
        // If editing is complete, finally seek to the chosen time.
        if editing {
            timeObserver.pause(true)
        } else {
            // Since the seek bar Slider is bound to the view's currentTime value and that value
            // will update before this block executes, currentTime will be up-to-date for use here.
            let requestedTime = CMTime(seconds: currentTime, preferredTimescale: CMTimeScale(1000.0))
            
            // Once the seek executes, we can continue observing time controlled by the AVPlayer.
            player.seek(to: requestedTime) { _ in
                self.timeObserver.pause(false)
                self.isPlaying = true
            }
        }
    }
    
    private func formatted(timeSeconds: Double) -> String {
        // Display seconds as a suitable media time (00:00)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter.string(from: timeSeconds) ?? ""
    }
}
