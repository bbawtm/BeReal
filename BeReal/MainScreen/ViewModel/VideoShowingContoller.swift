//
//  VideoShowingContoller.swift
//  BeReal
//
//  Created by Vadim Popov on 04.02.2023.
//

import UIKit
import AVFoundation
import AVKit


// MARK: Separate video output page

class VideoShowingContoller:
    UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    WithRefreshablePreview
{
    public var videoModel: VideoModel? = nil
    private lazy var videoPickerProvider = VideoPickerProviderModel(delegate: self, videoModel: videoModel!)
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var playIcon: UIImageView!
    @IBOutlet var nothingHereIcon: UIImageView!
    
    override func viewDidLoad() {
        guard let videoModel else { fatalError("No video model provided") }
        setPreviewForDate(videoModel.date)
        
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
    
    // MARK: - Picker Functions
    
    @IBAction private func setNewVideo() {
        videoPickerProvider.recordVideo()
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        self.videoPickerProvider.saveRecievedVideo(picker, didFinishPickingMediaWithInfo: info)
    }
    
    func setPreviewForDate(_ date: Date) {
        guard let videoModel else { fatalError("No video model provided") }
        guard videoModel.date == date else { return }
        videoModel.refreshData()
        if videoModel.videoURL != nil {
            imgView.image = videoModel.previewImage
            imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playVideo)))
            playIcon.isHidden = false
            nothingHereIcon.isHidden = true
        } else {
            playIcon.isHidden = true
            nothingHereIcon.isHidden = false
        }
        
        if let prev = navigationController?.previousViewController as? WithRefreshablePreview {
            prev.setPreviewForDate(date)
        }
    }
    
    // MARK: - Share popover subview
    
    @IBAction private func sharePopoverSubview(sender: UIButton) {
        guard let url = videoModel?.videoURL else {
            let errorAlert = UIAlertController(
                title: "Nothing to share",
                message: "There is no video here",
                preferredStyle: .alert
            )
            errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(errorAlert, animated: true)
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
//        activityViewController.popoverPresentationController?.sourceView = self.view.viewWithTag(6500214) as? UIButton
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Pre-configuring activity items
        activityViewController.activityItemsConfiguration = [
        UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]
        
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true)
    }
    
}


extension UINavigationController {
    var previousViewController: UIViewController? { viewControllers.last { $0 != topViewController } }
}
