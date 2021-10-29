//
//  VideoPlayer.swift
//  MagicCamera
//
//  Created by William on 2021/3/24.
//

import SwiftUI
import AVKit
import AVFoundation

// This is the UIView that contains the AVPlayerLayer for rendering the video
class VideoPlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private var player: AVQueuePlayer?
  
    init(url: URL) {
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)

        super.init(frame: .zero)
    
        player = AVQueuePlayer()
        backgroundColor = .black
        playerLayer.player = player
        layer.addSublayer(playerLayer)
        
        // Create a new player looper with the queue player and template item
        playerLooper = AVPlayerLooper(player: player!, templateItem: item)

        // Start the movie
        player?.play()

    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    override func layoutSubviews() {
        super.layoutSubviews()
    
        playerLayer.frame = bounds
    }
    
    func cleanUp() {
        player?.pause()
        player?.removeAllItems()
    }
  
}

// This is the SwiftUI view which wraps the UIKit-based PlayerUIView above
struct VideoPlayerView: UIViewRepresentable {
    let url: URL
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<VideoPlayerView>) {
        // This function gets called if the bindings change, which could be useful if
        // you need to respond to external changes, but we don't in this example
    }
    
    func makeUIView(context: UIViewRepresentableContext<VideoPlayerView>) -> UIView {
        let uiView = VideoPlayerUIView(url: url)
        return uiView
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        guard let playerUIView = uiView as? VideoPlayerUIView else {
            return
        }
        
        playerUIView.cleanUp()
    }
}

// This is the SwiftUI view which contains the player and its controls
struct VideoPlayerContainerView : View {
    private let url: URL
  
    init(url: URL) {
        self.url = url
    }
  
    var body: some View {
        VStack {
            VideoPlayerView(url: url)
        }
        .onDisappear {
            // When this View isn't being shown anymore stop the player
        }
    }
}
