//
//  VideoItem.swift
//  BeReal
//
//  Created by Vadim Popov on 03.02.2023.
//

import UIKit
import AVFoundation


class VideoModel {
    
    public var videoURL: URL? = nil
    public var previewImage = UIImage(named: "emptyPreview")
    public var date: Date
    
    init(date: Date) {
        self.date = date
        refreshData()
    }
    
    public func refreshData() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let customDirectory = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("videos", conformingTo: .directory)
        if !FileManager.default.fileExists(atPath: customDirectory.path) {
            return
        }
        let fileToSearch = customDirectory.appendingPathComponent(pathStringByDate(date), conformingTo: .data)
        if !FileManager.default.fileExists(atPath: fileToSearch.path) {
            return
        }
        self.videoURL = fileToSearch
        self.previewImage = imageFromVideo(url: fileToSearch, at: 0)
    }
    
    private func pathStringByDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.timeZone = .gmt
        let dateStr = formatter.string(from: date)
        return "vid-\(dateStr).mp4"
    }
    
    private func imageFromVideo(url: URL, at time: TimeInterval) -> UIImage? {
        let asset = AVURLAsset(url: url)

        let assetIG = AVAssetImageGenerator(asset: asset)
        assetIG.appliesPreferredTrackTransform = true
        assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels

        let cmTime = CMTime(seconds: time, preferredTimescale: 60)
        let thumbnailImageRef: CGImage
        do {
            thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
        } catch let error {
            print("Error: \(error)")
            return nil
        }

        return UIImage(cgImage: thumbnailImageRef)
    }
    
}
