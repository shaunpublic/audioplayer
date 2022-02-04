//
//  AVPlayerItem+StatusString.swift
//

import SwiftUI
import AVKit

extension AVPlayerItem {
    
    var statusString: String {
        switch status {
        case .readyToPlay: return "readyToPlay"
        case .failed: return "failed"
        case .unknown: return "unknown"
        @unknown default:
            return "@unknown"
        }
    }
}
