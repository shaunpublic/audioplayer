//
//  AudioPlayerButton.swift
//
//  A custom view, housing a button that uses a tinted,
//  fixed-size system icon.
//

import SwiftUI

struct AudioPlayerButton: View {
    
    var systemName: String
    var action: () -> ()
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .resizable()
                .frame(width: 32.0, height: 32.0)
                .tint(Color.black)
        }
    }
}
