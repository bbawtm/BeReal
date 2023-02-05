//
//  VideoItem.swift
//  BeReal
//
//  Created by Vadim Popov on 03.02.2023.
//

import UIKit


class VideoModel {
    
    public var image = UIImage(named: "emptyPreview")
    public var date: Date
    
    init(date: Date) {
        self.date = date
    }
    
}
