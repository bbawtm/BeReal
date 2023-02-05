//
//  VideoShowingContoller.swift
//  BeReal
//
//  Created by Vadim Popov on 04.02.2023.
//

import UIKit


class VideoShowingContoller: UIViewController {
    
    var videoModel: VideoModel? = nil
    
    @IBOutlet var imgView: UIImageView!
    
    override func viewDidLoad() {
        guard let videoModel else { fatalError("No video model provided") }
        
        self.imgView.image = videoModel.image
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = .gmt
        self.title = dateFormatter.string(from: videoModel.date)
    }
    
}
