//
//  VideoShowingContoller.swift
//  BeReal
//
//  Created by Vadim Popov on 04.02.2023.
//

import UIKit
import AVFoundation
import AVKit


class VideoShowingContoller: UIViewController {
    
    var videoModel: VideoModel? = nil
    
    @IBOutlet var imgView: UIImageView!
    
    override func viewDidLoad() {
        guard let videoModel else { fatalError("No video model provided") }
        
        if videoModel.videoURL != nil {
            imgView.image = videoModel.previewImage
            imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playVideo)))
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = .gmt
        self.title = dateFormatter.string(from: videoModel.date)
    }
    
    @objc private func playVideo() {
        guard let videoURL = videoModel?.videoURL else { return }
        
        let videoAsset = (AVAsset(url: videoURL))
        let playerItem = AVPlayerItem(asset: videoAsset)
        
        let player = AVPlayer(playerItem: playerItem)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player

        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
}
