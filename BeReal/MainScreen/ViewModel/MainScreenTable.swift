//
//  MainScreenTable.swift
//  BeReal
//
//  Created by Vadim Popov on 21.01.2023.
//

import UIKit
import MobileCoreServices
import AVKit
import AVFoundation
import UniformTypeIdentifiers


class MainScreenTable:
    UICollectionViewController,
    UICollectionViewDelegateFlowLayout,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
{
    
    // MARK: - Variables
    
    public var visibleMonth = MonthModel(2, 2023)
    private let weekDayNamings = ["пн", "вт", "ср", "чт", "пт", "сб", "вс"]
    
    private lazy var videoRecordPicker: UIImagePickerController? = {
        let picker = UIImagePickerController()
        picker.delegate = self
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
        picker.delegate = self
        picker.mediaTypes = [UTType.movie.identifier]
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }()
    
    private let monthField = {
        let monthField = UITextField()
        monthField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.175)
        monthField.setMonthPickerAsInputView(selector: #selector(refreshForMonth))
        
        let widthPaddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        monthField.leftView = widthPaddingView
        monthField.leftViewMode = .always
        monthField.rightView = widthPaddingView
        monthField.rightViewMode = .always
        monthField.layer.cornerRadius = 10
        monthField.tintColor = .clear
        
        return monthField
    }()
    
    private let newVideoButton = {
        var newVideoButtonConfig = UIButton.Configuration.filled()
        newVideoButtonConfig.title = "Capture new"
        newVideoButtonConfig.buttonSize = .large
        newVideoButtonConfig.cornerStyle = .capsule
        let newVideoButton = UIButton(configuration: newVideoButtonConfig)
        return newVideoButton
    }()
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        self.collectionView.register(
            UINib(nibName: "MainScreenWeekDayCellView", bundle: nil),
            forCellWithReuseIdentifier: "mainScreenWeekDayCell"
        )
        self.collectionView.register(
            UINib(nibName: "MainScreenCellView", bundle: nil),
            forCellWithReuseIdentifier: "mainScreenVideoCell"
        )
        
        refreshForMonth()
        newVideoButton.addTarget(self, action: #selector(recordVideo), for: .touchUpInside)
        
        view.addSubview(newVideoButton)
        view.addSubview(monthField)
        
        newVideoButton.translatesAutoresizingMaskIntoConstraints = false
        monthField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            newVideoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            newVideoButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            monthField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            monthField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            monthField.heightAnchor.constraint(equalToConstant: 38),
        ])
    }
    
    // MARK: - Collection view properties
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if section == 0 {
            return 7
        } else {
            return visibleMonth.items.count + (visibleMonth.firstWeekDay - 2)
        }
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let newCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "mainScreenWeekDayCell",
                for: indexPath
            ) as? MainScreenWeekDayCell else {
                fatalError("Cannot reuse week day cell")
            }
            newCell.label.text = weekDayNamings[indexPath.row]
            return newCell
        } else {
            guard let newCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "mainScreenVideoCell",
                for: indexPath
            ) as? MainScreenVideoCell else {
                fatalError("Cannot reuse main cell")
            }
            
            let emptyCellCount = visibleMonth.firstWeekDay - 2
            newCell.layer.cornerRadius = 5
            if indexPath.item >= emptyCellCount {
                newCell.imgView.image = visibleMonth.items[indexPath.item - emptyCellCount].previewImage
                newCell.dayLabel.text = String(indexPath.item + 1 - emptyCellCount)
                newCell.layer.borderColor = CGColor(gray: 1, alpha: 1)
                newCell.layer.borderWidth = 0.75
            } else {
                newCell.dayLabel.text = ""
                newCell.imgView.image = nil
                newCell.layer.borderColor = nil
                newCell.layer.borderWidth = 0
            }
            
            return newCell
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let cellWidth = (collectionView.frame.size.width - 70) / 7
        if indexPath.section == 0 {
            return CGSize(width: cellWidth, height: 30)
        } else {
            return CGSize(width: cellWidth, height: cellWidth * 4 / 3)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.frame.size.width, height: 90)
        }
        return CGSize()
    }
    
    // MARK: - Segues
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 || indexPath.item < visibleMonth.firstWeekDay - 2 {
            return
        }
        let itemIndex = indexPath.item - (visibleMonth.firstWeekDay - 2)
        let videoModel = visibleMonth.items[itemIndex] as VideoModel
        if videoModel.videoURL != nil {
            performSegue(withIdentifier: "gotoVideoShowingScreen", sender: videoModel)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? VideoShowingContoller,
           let vm = sender as? VideoModel
        {
            destinationVC.videoModel = vm
        }
    }
    
    // MARK: - Choose month
    
    @objc private func refreshForMonth() {
        guard let inp = self.monthField.inputView as? MonthPickerView else {
            return
        }
        monthField.text = "\(inp.month) \(inp.year)"
        monthField.resignFirstResponder()
        
        guard let monthInd = MonthModel.allMonths.firstIndex(of: inp.month),
              let yearNum = Int(inp.year)
        else {
            fatalError("Incorrect month/year")
        }
        self.visibleMonth = MonthModel(Int(monthInd) + 1, yearNum)
        self.collectionView.reloadData()
    }
    
    // MARK: - Capture video
    
    @objc private func recordVideo() {
        let selectionAlert = UIAlertController(
            title: "Select source",
            message: nil,
            preferredStyle: .actionSheet
        )
        selectionAlert.addAction(UIAlertAction(title: "Record video", style: .default, handler: { action in
            guard let picker = self.videoRecordPicker else {
                self.simulatorVideoCaptureAlert()
                return
            }
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                self.present(picker, animated: true, completion: nil)
            }
        }))
        selectionAlert.addAction(UIAlertAction(title: "Choose from Photos", style: .default, handler: { action in
            self.present(self.videoPhotosPicker, animated: true, completion: nil)
        }))
        selectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(selectionAlert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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
            let currentDay = formatter.string(from: Date())
            
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
    
    private func simulatorVideoCaptureAlert() {
        let simulatorVideoAlert = UIAlertController(title: "This is a simulator", message: "It's unable to run camera", preferredStyle: .alert)
        simulatorVideoAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(simulatorVideoAlert, animated: true)
    }
    
}
