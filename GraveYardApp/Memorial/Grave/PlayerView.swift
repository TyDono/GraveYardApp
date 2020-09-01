//
//  PlayerView.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 9/1/20.
//  Copyright © 2020 Tyler Donohue. All rights reserved.
//

import AVFoundation
import UIKit

class PlayerView: UIView {

    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
