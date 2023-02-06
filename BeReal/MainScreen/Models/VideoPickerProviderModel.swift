//
//  VideoPickerProviderModel.swift
//  BeReal
//
//  Created by Vadim Popov on 06.02.2023.
//

import UIKit
import UniformTypeIdentifiers


class VideoPickerProviderModel {
    
    typealias DelegateType = UIImagePickerControllerDelegate & UINavigationControllerDelegate & UIViewController
    
    private let delegate: DelegateType
    private let date: Date
    
    public init(delegate: DelegateType, date: Date = Date()) {
        self.delegate = delegate
        self.date = date
    }
    
    private lazy var videoRecordPicker: UIImagePickerController? = {
        let picker = UIImagePickerController()
        picker.delegate = self.delegate
        picker.mediaTypes = [UTType.movie.identifier]
#if targetEnvironment(simulator)
        return nil
#else
        picker.sourceType = .camera
        picker.allowsEditing = false
        return picker
#endif
    }()
    
    private lazy var videoPhotosPicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self.delegate
        picker.mediaTypes = [UTType.movie.identifier]
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }()
    
    @objc public func recordVideo() {
        let selectionAlert = UIAlertController(
            title: "Select a source",
            message: nil,
            preferredStyle: .actionSheet
        )
        selectionAlert.addAction(UIAlertAction(title: "Record video", style: .default, handler: { action in
            guard let picker = self.videoRecordPicker else {
                self.simulatorVideoCaptureAlert()
                return
            }
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                self.delegate.present(picker, animated: true, completion: nil)
            }
        }))
        selectionAlert.addAction(UIAlertAction(title: "Choose from Photos", style: .default, handler: { action in
            self.delegate.present(self.videoPhotosPicker, animated: true, completion: nil)
        }))
        selectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.delegate.present(selectionAlert, animated: true)
    }
    
    private func simulatorVideoCaptureAlert() {
        let simulatorVideoAlert = UIAlertController(title: "This is a simulator", message: "It's unable to run camera", preferredStyle: .alert)
        simulatorVideoAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.delegate.present(simulatorVideoAlert, animated: true)
    }
    
    public func saveRecievedVideo(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        if let pickedVideo: URL = (info[UIImagePickerController.InfoKey.mediaURL] as? URL) {
            let videoData = try? Data(contentsOf: pickedVideo)
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            let customDirectory = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("videos", conformingTo: .directory)
            if !FileManager.default.fileExists(atPath: customDirectory.path) {
                do {
                    try FileManager.default.createDirectory(atPath: customDirectory.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            formatter.timeZone = .gmt
            let currentDay = formatter.string(from: self.date)
            
            let dataPath = customDirectory.appendingPathComponent("vid-\(currentDay).mp4", conformingTo: .data)
            do {
                try videoData?.write(to: dataPath, options: [])
                print("Saved to " + dataPath.absoluteString)
            } catch {
                print(error.localizedDescription)
            }
        }
        videoPhotosPicker.dismiss(animated: true)
        videoRecordPicker?.dismiss(animated: true)
    }
    
}
