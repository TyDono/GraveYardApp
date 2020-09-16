//
//  EditGraveTableViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/28/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import AVKit
import AVFoundation
import MobileCoreServices


class EditGraveTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var deathDateLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var videoPreviewUIImage: UIImageView!
    @IBOutlet weak var publicIsTrueSwitch: UISwitch!
    @IBOutlet weak var publicIsTrueLabel: UILabel!
    @IBOutlet weak var birthDateCell: UITableViewCell!
    @IBOutlet weak var birthLocationCell: UITableViewCell!
    @IBOutlet weak var deathDateCell: UITableViewCell!
    @IBOutlet weak var deathLocationCell: UITableViewCell!
    @IBOutlet weak var birthLabel: UILabel!
    @IBOutlet weak var deathLabel: UILabel!
    @IBOutlet weak var birthSwitch: UISwitch!
    @IBOutlet weak var deathSwitch: UISwitch!
    @IBOutlet weak var deleteHeadstoneButton: UIButton!
    @IBOutlet weak var graveMainImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    @IBOutlet weak var birthLocationTextField: UITextField!
    @IBOutlet weak var deathDatePicker: UIDatePicker!
    @IBOutlet weak var deathLocationTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var pinQuoteTextField: UITextField!
    @IBOutlet weak var familyStatusTextView: UITextView!
    
    // MARK: - Propeties
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var currentUser: Grave?
    var userId: String?
    var creatorId: String?
    let dateFormatter = DateFormatter()
    var imageString: String?
    var currentGraveId: String? = MapViewController.shared.currentGraveId
    var graveProfileImage: GraveProfileImage?
    var graveProfileImages = [UIImage]()
    var currentGraveLocationLongitude: String?
    var currentGraveLocationLatitude: String?
    let storage = Storage.storage()
    var currentImageDataCount: Double?
    var player = AVPlayer()
    var playerViewController = AVPlayerViewController()
    var birthDate: String = ""
    var deathDate: String = ""
    var storyImageStringArray: [String] = []
    var arrayOfStoryImageIDs: [String] = []
    var memorialCount: Int = 0
    var videoURLString: String?
    var videoURL: URL?
    var videoDataSize: Double = 0.0
    var oldVideoDataSize: Double = 0.0
    var storyCount: Int = 0
    var introVideoToBeCleared: Bool = false
    var graveProfileImageToBeCleared: Bool = false
    
    let birthDatePickerCellIndexPath = IndexPath(row: 3, section: 1)
    let deathDatePickerCellIndexPath = IndexPath(row: 3, section: 2)
    var isDeathDatePickerShown: Bool = false {
        didSet {
            birthDatePicker.isHidden = !isDeathDatePickerShown
        }
    }
    var isCheckOutDatePickerShown: Bool = false {
        didSet {
            deathDatePicker.isHidden = !isCheckOutDatePickerShown
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        getUserMemorialCount()
        getGraveData()
        //chageTextColor()
        self.deleteHeadstoneButton.layer.cornerRadius = 10
        self.playButton.layer.cornerRadius = 10
//        self.videoPreviewUIImage.contentMode = .scaleToFill
//        self.videoPreviewUIImage.image = UIImage(named: "icons8-video-100")
        switchEnabler()
    }
    
    // MARK: - Functions
    
    func getUserMemorialCount() {
        guard let safeCurrentAuthID = self.currentAuthID else { return }
        let userRef = self.db.collection("userProfile").whereField("currentUserAuthId", isEqualTo: safeCurrentAuthID)
        userRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    if let memorialCount = document.data()["memorialCount"] as? Int {
                        self.memorialCount = memorialCount
                    }
                }
            }
        }
    }
    
    func updateUserMemorialCount() {
        guard let currentId = currentAuthID else { return }
        self.memorialCount -= 1
        MyFirebase.memorialCount -= 1
        db.collection("userProfile").document(currentId).updateData([
            "memorialCount": self.memorialCount
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func fileSize(forURL url: Any) -> Double {//takes in url and gets its size. returns file in mb size
        var fileURL: URL?
        var fileSize: Double = 0.0
        if (url is URL) || (url is String) {
            if (url is URL) {
                fileURL = url as? URL
            }
            else {
                fileURL = URL(fileURLWithPath: url as! String)
            }
            var fileSizeValue = 0.0
            try? fileSizeValue = (fileURL?.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! Double?)!
            if fileSizeValue > 0.0 {
                fileSize = (Double(fileSizeValue))/(1024 * 1024)
                fileSize = Double(round(10*fileSize)/10)
            }
        }
        return fileSize
    }
    
    func videoPreviewImage() {
        guard let safeVideoURL = self.videoURL else { return }
        AVAsset(url: safeVideoURL).generateThumbnail { [weak self] (image) in
             DispatchQueue.main.async {
                 guard let image = image else { return }
                 self?.videoPreviewUIImage.image = image
                self?.videoPreviewUIImage.contentMode = .scaleAspectFit
             }
         }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            graveMainImage.image = selectedImage
            graveProfileImages.append(selectedImage)
            self.graveMainImage.reloadInputViews()
        } else if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            self.videoDataSize = self.fileSize(forURL: videoURL)
            print(self.videoDataSize)
            if self.videoDataSize > 5.0 {
               print("IT TO BIG OF A FILE")
                dismiss(animated: true, completion: nil)
                let alertFileToBig = UIAlertController(title: "Video Upload Failed!", message: "Each video uploaded can only be 5mb in size. Please choose a smaller video to upload. Thank you.", preferredStyle: .alert)
                alertFileToBig.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alertFileToBig.dismiss(animated: true, completion: nil)
                }))
                self.present(alertFileToBig, animated: true, completion: nil)
            } else {
                self.videoURL = videoURL
                self.videoPreviewImage()
            }
            print("file URL: ", videoURL)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func chageTextColor() {
        tableView.separatorColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
    }
    
    func switchEnabler() {
        if birthSwitch.isOn == true {
            birthLabel.text = "Enabled"
            birthDateCell.isHidden = false
            birthLocationCell.isHidden = false
        } else {
            birthLabel.text = "Disabled"
            birthDateCell.isHidden = true
            birthLocationCell.isHidden = true
        }
        if deathSwitch.isOn == true {
            deathLabel.text = "Enabled"
            deathDateCell.isHidden = false
            deathLocationCell.isHidden = false
        } else {
            deathLabel.text = "Disabled"
            deathDateCell.isHidden = true
            deathLocationCell.isHidden = true
        }
        if publicIsTrueSwitch.isOn == true {
            publicIsTrueLabel.text = "Public"
        } else {
            publicIsTrueLabel.text = "Private"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (birthDatePickerCellIndexPath.section,
              birthDatePickerCellIndexPath.row):
            if isDeathDatePickerShown {
                return 216.0
            } else {
                return 0.0
            }
        case (deathDatePickerCellIndexPath.section,
              deathDatePickerCellIndexPath.row):
            if isCheckOutDatePickerShown {
                return 216.0
            } else {
                return 0.0
            }
        case (0, 0):
            return 246
        case (0, 4):
            return 356
        case (0, 5):
            return 306
        default: return 44.0
        }
    }

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch (indexPath.section, indexPath.row) {
        case (birthDatePickerCellIndexPath.section,
        birthDatePickerCellIndexPath.row - 1):

            if isDeathDatePickerShown {
                isDeathDatePickerShown = false
            } else if isCheckOutDatePickerShown {
                isCheckOutDatePickerShown = false
                isDeathDatePickerShown = true
            } else {
                isDeathDatePickerShown = true
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        case (deathDatePickerCellIndexPath.section,
        deathDatePickerCellIndexPath.row - 1):
            if isCheckOutDatePickerShown {
                isCheckOutDatePickerShown = false
            } else if isDeathDatePickerShown {
                isDeathDatePickerShown = false
                isCheckOutDatePickerShown = true
            } else {
                isCheckOutDatePickerShown = true
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        default:
            break
        }
    }
    
    //maybe used for a later date. no longer tracking data use of entire user.
//    func updateUserData() {
//        db = Firestore.firestore()
//        guard let currentId = currentAuthID else { return }
//        let newDataInUse = MyFirebase.currentDataUsage! - self.oldVideoDataSize + self.videoDataSize
//        print(newDataInUse)
//        if newDataInUse > 5.0 {
//            print("\(newDataInUse) is to big")
//            return
//        } else {
//            MyFirebase.currentDataUsage = newDataInUse
//            db.collection("userProfile").document(currentId).updateData([
//                "dataCount": MyFirebase.currentDataUsage!
//            ]) { err in
//                if let err = err {
//                    print("Error updating document: \(err)")
//                } else {
//                    print("Document successfully updated")
//                }
//            }
//        }
//    }
    
    func getGraveData() {
        dateFormatter.dateStyle = .medium
        guard let safeCurrentGraveId = self.currentGraveId else { return }
        print(safeCurrentGraveId)
        let graveRef = self.db.collection("grave").whereField("graveId", isEqualTo: safeCurrentGraveId) // this should be the grave id that was tapped on
        graveRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    if let creatorId = document.data()["creatorId"] as? String,
                        let profileImageId = document.data()["profileImageId"] as? String,
                        let name = document.data()["name"] as? String,
                        let birthDate = document.data()["birthDate"] as? String,
                        let birthLocation = document.data()["birthLocation"] as? String,
                        let deathDate = document.data()["deathDate"] as? String,
                        let deathLocation = document.data()["deathLocation"] as? String,
                        let graveId = document.data()["graveId"] as? String?,
//                        let familyStatus = document.data()["familyStatus"] as? String,
                        let bio = document.data()["bio"] as? String,
                        let pinQuote = document.data()["pinQuote"] as? String,
                        let graveLocationLatitude = document.data()["graveLocationLatitude"] as? String,
                        let graveLocationLongitude = document.data()["graveLocationLongitude"] as? String,
                        let birthSwitchIsOn = document.data()["birthSwitchIsOn"] as? Bool,
                        let deathSwitchIsOn = document.data()["deathSwitchIsOn"] as? Bool,
                        let publicIsTrue = document.data()["publicIsTrue"] as? Bool,
                        let videoURL = document.data()["videoURL"] as? String,
                        let storyCount = document.data()["storyCount"] as? Int,
                        let arrayOfStoryImageIDs = document.data()["arrayOfStoryImageIDs"] as? [String] {
                        
                        self.imageString = profileImageId
                        self.dateFormatter.dateStyle = .medium
                        if let safeBirthDate = self.dateFormatter.date(from:birthDate) {
                            self.birthDatePicker.date = safeBirthDate
                            self.birthDateLabel.text = birthDate
                        }
                        print(deathDate)
                        if let safeDeathDate = self.dateFormatter.date(from:deathDate) {
                            self.deathDatePicker.date = safeDeathDate
                            self.deathDateLabel.text = deathDate
                        }
                        self.nameTextField.text = name
                        self.birthLocationTextField.text = birthLocation
                        self.currentGraveId = graveId
                        self.deathLocationTextField.text = deathLocation
                        //self.familyStatusTextView.text = familyStatus
                        self.bioTextView.text = bio
                        self.pinQuoteTextField.text = pinQuote
                        self.creatorId = creatorId
                        self.currentGraveLocationLatitude = graveLocationLatitude
                        self.currentGraveLocationLongitude = graveLocationLongitude
                        self.birthSwitch.isOn = birthSwitchIsOn
                        self.deathSwitch.isOn = deathSwitchIsOn
                        self.publicIsTrueSwitch.isOn = publicIsTrue
                        self.videoURLString = videoURL
                        self.storyCount = storyCount
                        self.arrayOfStoryImageIDs = arrayOfStoryImageIDs
                        self.switchEnabler()
                        self.getVideo()
                        self.getImages() //call this last
                    }
                }
            }
        }
    }
    
    func getStoryData() {
        guard let safeCurrentGraveId = self.currentGraveId else { return }
        let graveRef = self.db.collection("grave").whereField("graveId", isEqualTo: safeCurrentGraveId)
        graveRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    if (document.data()["creatorId"] as? String) != nil {

                    }
                }
            }
        }
    }
    
    func getVideo() {
        if let videoString = self.videoURLString {
            let storageRef = storage.reference()
            let graveProfileVideo = storageRef.child("graveProfileVideos/\(videoString)")
            graveProfileVideo.getData(maxSize: (1000000000), completion:  { (data, err) in
                guard let data = data else  { return }
                graveProfileVideo.downloadURL { (url, err) in
                    if let urlText = url {
                        self.videoURL = urlText
                        self.videoPreviewImage()
                    } else {
                        print(err as Any)
                    }
                }
                var videoSize = Double(data.count)/(1024 * 1024)
                videoSize =  Double(round(10*videoSize)/10)
                self.videoDataSize = videoSize
                print(data)
            })
        }
    }
    
    func getImages() {
        if let imageStringId = self.imageString {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("graveProfileImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (5000000), completion:  { (data, err) in
                guard let data = data else { return }
                guard let image = UIImage(data: data) else { return }
                self.graveMainImage.image = image
                guard let imageDataBytes = image.jpegData(compressionQuality: 0.05) else { return }
                self.currentImageDataCount = Double(imageDataBytes.count)
            })
        } else {
            return
        }
    }
    
    func uploadFirebaseImages(_ image: UIImage, completion: @escaping ((_ url: URL?) -> () )) {
        guard let imageStringId = self.imageString else { return }
        let storageRef = Storage.storage().reference().child("graveProfileImages/\(imageStringId)")
        guard let imageData = image.jpegData(compressionQuality: 0.05) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            if error == nil, metaData != nil {
                print("got grave image")
                storageRef.downloadURL(completion: { (url, error) in
                    completion(url)
                })
            } else {
                completion(nil)
            }
        }
    }
    
    func deleteGraveProfileImage() {
        guard let safeImageString = self.imageString else { return }
        let imageRef = self.storage.reference().child("graveProfileImages/\(safeImageString)")
        imageRef.delete { err in
            if let error = err {
                print(error)
            } else {
                print("files deleted")
            }
        }
    }
    
    func deleteGraveProfileVideo() {
        guard let safeVideoURLString = self.videoURLString else { return }
        let imageRef = self.storage.reference().child("graveProfileVideos/\(safeVideoURLString)")
        imageRef.delete { err in
            if let error = err {
                print(error)
            } else {
                print("files deleted")
            }
        }
    }
    
    func deleteGraveStories() {
        let graveStoryRef = self.db.collection("stories")
        let getStories = graveStoryRef.whereField("graveId", isEqualTo: self.currentGraveId!)
        getStories.getDocuments { (snapshot, err) in
            if err != nil {
                print(err as Any)
            } else {
                for document in (snapshot?.documents)! {
                    //                    if let creatorId = document.data()["creatorId"] as? String,
                    //                        let profileImageId = document.data()["profileImageId"] as? String,
                }
            }
            
        }
        
        graveStoryRef.document("").delete() {
            err in
            if err == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                    self.performSegue(withIdentifier: "unwindToMap", sender: nil)
                }
            }
        }
    }
    
    func deletedStoryImages() {
        for i in self.arrayOfStoryImageIDs {
            self.storage.reference().child("storyImages/\(i)").delete { (err) in
                if err == nil {
                    // no error
                } else {
                    // this might be called since they might not have images to be deleted
                    print(err as Any)
                }
            }
        }
    }
    
    func convertVideo(toMPEG4FormatForVideo inputURL: URL, outputURL: URL, handler: @escaping (AVAssetExportSession) -> Void) { //converts video to mp4
        try? FileManager.default.removeItem(at: outputURL as URL) //there was no file detected one time on the first try.
        let asset = AVURLAsset(url: inputURL as URL, options: nil)
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously(completionHandler: {
            handler(exportSession)
        })
    }
    
    func uploadToFireBaseVideo(url: URL,
                               success : @escaping (String) -> Void,
                               failure : @escaping (Error) -> Void) {
        
        guard let safeVideoURL = self.videoURLString else { return }
        let name = "\(safeVideoURL)"
        let path = NSTemporaryDirectory() + name
        let dispatchgroup = DispatchGroup()
        dispatchgroup.enter()
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputurl = documentsURL.appendingPathComponent(name)
        var ur = outputurl
        self.convertVideo(toMPEG4FormatForVideo: url as URL, outputURL: outputurl) { (session) in
            ur = session.outputURL!
            dispatchgroup.leave()
        }
        dispatchgroup.wait()
        let data = NSData(contentsOf: ur as URL)
        do {
            try data?.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch {
            print(error)
        }
        let storageRef = Storage.storage().reference().child("graveProfileVideos/\(name)")
        if let uploadData = data as Data? {
            storageRef.putData(uploadData, metadata: nil
                , completion: { (metadata, error) in
                    if let error = error {
                        failure(error)
                    } else {
                        let strPic:String = (metadata?.path)!
                        success(strPic)
                    }
            })
        }
    }
    
    func deleteGraveStoryVideo() {
        guard let safeVideoURLString = self.videoURLString else { return }
        self.storage.reference().child("graveProfileVideos/\(safeVideoURLString)").delete { (err) in
            if err == nil {
                // no error
            } else {
                // this might be called since they might not have images to be deleted
                print(err as Any)
            }
        }
    }
    
    func playURLVideo(url: URL) {
        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player
        self.present(vc, animated: true) { vc.player?.play() }
    }

//    func uploadVideoToFirebaseStorge() {
//        guard let safeVideoURL = self.videoURL else { return }
////        if let videoURL == self.videoURL {
//            print(safeVideoURL)
//            let storageRef = Storage.storage().reference().child("graveProfileVideos/\(safeVideoURL)")
//            storageRef.putFile(from: safeVideoURL, metadata: nil) { (metaData, error) in
//                if error != nil {
//                    print("failed to upload video file to firebase \(error)")
//                    return
//                }
////                let size = metaData // this will get the size of the video for tracking purposes
//                storageRef.downloadURL { (url, error) in
//                    guard let downloadURL = url else {
//                        print("an error has occured \(error)")
//                        return
//                    }
//                }
//            }
////        }
//    }
            
    // MARK: - Actions
    
    @IBAction func clearGraveProfileImageButonTapped(_ sender: UIButton) {
        let clearedImage = UIImage(named: "icons8-add-image-90")
        graveMainImage.image = clearedImage
        graveProfileImageToBeCleared = true
        self.tableView.reloadData()
    }
    
    @IBAction func clearGraveIntroVideoButtonTapped(_ sender: UIButton) {
        let clearedImage = UIImage(named: "addVideo")
        videoPreviewUIImage.image = clearedImage
        introVideoToBeCleared = true
        self.tableView.reloadData()
    }
    
    @IBAction func saveGraveInfoTapped(_ sender: UIBarButtonItem) { //  MOST OF COMMENTED OUT CODE WILL BE RE-ADDED WHEN PREMIUM IS LIVE TO KEEP TRACK OF THEIR DATA USE AND TO LET THE USERS KNOW. ADD THIS TO NEWGRAVESTORYVIEWCONTROLLER WHEN PREMIUM IS LIVE
        if nameTextField.text == "" {
            nameTextField.isError(baseColor: UIColor.red.cgColor, numberOfShakes: 3, revert: true)
            return
        } else {
            //self.updateUserData()
            switch introVideoToBeCleared {
            case false:
                if let safeVideoURL = self.videoURL {
                    self.uploadToFireBaseVideo(url: safeVideoURL, success: { (String) in
                        if self.currentImageDataCount != nil {
                            print("successfully uploaded video to Firebase Storage")
                        }
                    }) { (Error) in
                        print("error \(Error)")
                    }
                }
            case true:
                self.deleteGraveStoryVideo()
            }

            //        guard let unwrappedGraveImage = graveMainImage.image else { return } // the uplaod takes 2 long and needs a delay before segue is called
            //        guard let currentDataUseCount = MyFirebase.currentDataUsage else { return }
            //        var checkDataCap: Int = 0
            switch graveProfileImageToBeCleared {
            case false:
                for image in graveProfileImages {
                    uploadFirebaseImages(image) { (url) in
                        guard image.jpegData(compressionQuality: 0.05) != nil else { return }
                        if self.currentImageDataCount != nil {
                            print("image uploaded")
                        }
                        guard url != nil else { return }
                    }
                }
            case true:
                self.deleteGraveProfileImage()
            }

            
            let creatorId = currentAuthID!
            guard let graveId = self.currentGraveId  else { return } // this is the grave id that was tapped on
            guard let profileImageId = self.imageString else { return }
            guard let name = nameTextField.text else { return }
            if birthSwitch.isOn == true {
                let birth = birthDatePicker.date
                self.birthDate = dateFormatter.string(from: birth)
            } else {
                self.birthDate = ""
            }
            guard let birthLocation = birthLocationTextField.text else { return }
            if deathSwitch.isOn == true {
                let death = deathDatePicker.date
                self.deathDate = dateFormatter.string(from: death)
            } else {
                self.deathDate = ""
            }
            guard let deathLocation = deathLocationTextField.text else { return }
            let familyStatus =  "" //familyStatusTextView.text else { return }
            let arrayOfStoryImageIDs = self.arrayOfStoryImageIDs
            guard let bio = bioTextView.text else { return }
            guard let currentGraveLocationLatitude = self.currentGraveLocationLatitude  else { return }
            guard let currentGraveLocationLongitude = self.currentGraveLocationLongitude  else { return }
            guard let currentVideoURLString = self.videoURLString else { return }
            let allGraveIdentifier: String = "tylerRoolz"
            let storyCount = self.storyCount
            guard let pinQuote: String = self.pinQuoteTextField.text else { return }
            
            let grave = Grave(creatorId: creatorId,
                              graveId: graveId,
                              profileImageId: profileImageId,
                              name: name,
                              birthDate: self.birthDate,
                              birthLocation: birthLocation,
                              deathDate: self.deathDate,
                              deathLocation: deathLocation,
                              familyStatus: familyStatus,
                              bio: bio,
                              graveLocationLatitude: currentGraveLocationLatitude,
                              graveLocationLongitude: currentGraveLocationLongitude,
                              allGraveIdentifier: allGraveIdentifier,
                              pinQuote: pinQuote,
                              birthSwitchIsOn: self.birthSwitch.isOn,
                              deathSwitchIsOn: self.deathSwitch.isOn,
                              publicIsTrue: self.publicIsTrueSwitch.isOn,
                              videoURL: currentVideoURLString,
                              storyCount: storyCount,
                              arrayOfStoryImageIDs: arrayOfStoryImageIDs)
            
            let graveRef = self.db.collection("grave")
            graveRef.document(String(grave.graveId)).updateData(grave.dictionary){ err in
                if let err = err {
                    let alertFailure = UIAlertController(title: "Not Saved", message: "Sorry, there was an error while trying to save your Grave. Please try again.", preferredStyle: .alert)
                    alertFailure.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        alertFailure.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alertFailure, animated: true, completion: nil)
                    print(err)
                } else {
                    let alertSuccess = UIAlertController(title: "Memorial Saved!", message: "You have successfully save your Memorial data", preferredStyle: .alert)
                    alertSuccess.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        alertSuccess.dismiss(animated: true, completion: nil)
                        self.performSegue(withIdentifier: "unwindToGraveSegue", sender: nil)
                    }))
                    self.present(alertSuccess, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    @IBAction func changeImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        graveProfileImageToBeCleared = false
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func publicIsTrueSwitchWasTapped(_ sender: UISwitch) {
        if publicIsTrueSwitch.isOn == true {
            publicIsTrueLabel.text = "Public"
        } else {
            publicIsTrueLabel.text = "Private"
        }
    }
    
    @IBAction func birthSwitchWasTapped(_ sender: UISwitch) {
        if birthSwitch.isOn == true {
            birthLabel.text = "Enabled"
            birthDateCell.isHidden = false
            birthLocationCell.isHidden = false
        } else {
            birthLabel.text = "Disabled"
            birthDateCell.isHidden = true
            birthLocationCell.isHidden = true
        }
    }
    
    @IBAction func birthDatePickerWasTapped(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        birthDateLabel.text = dateFormatter.string(from: birthDatePicker.date)
    }
    
    @IBAction func deathSwitchWasTapped(_ sender: UISwitch) {
        if deathSwitch.isOn == true {
            deathLabel.text = "Enabled"
            deathDateCell.isHidden = false
            deathLocationCell.isHidden = false
        } else {
            deathLabel.text = "Disabled"
            deathDateCell.isHidden = true
            deathLocationCell.isHidden = true
        }
    }
    
    @IBAction func deathDatePickerWasTapped(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        deathDateLabel.text = dateFormatter.string(from: deathDatePicker.date)
    }
    
    
    @IBAction func deleteGraveButtonTapped(_ sender: UIButton) {
        let alerController = UIAlertController(title: "WARNING!", message: "This will delete all of the information on this Memorial along with it's stories!", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alerController.addAction(cancel)
        let delete = UIAlertAction(title: "DELETE", style: .destructive) { _ in
            let forcedUserId = self.currentAuthID!
            let forcedGraveId = self.currentGraveId!
            let userRef = self.db.collection("stories")
            print(self.storyImageStringArray)
            self.deletedStoryImages()
            self.deleteGraveProfileVideo()
            userRef.document(forcedUserId).delete() { err in //deletes stories, call story image delete before this
                if err == nil {
                    let storyRef = self.db.collection("grave")
                    storyRef.document(forcedGraveId).delete() { err in //deletes current grave
                        if err == nil {
                            self.updateUserMemorialCount()
                            if let safeImageString = self.imageString {
                                let storageImageRef = self.storage.reference().child("graveProfileImages/\(safeImageString)")
                                storageImageRef.delete { (error) in //deletes grave image
                                    if error == nil {
                                        let alertSuccess = UIAlertController(title: "Success", message: "You have successfully deleted this Memorial and all of it's content", preferredStyle: .alert)
                                        alertSuccess.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                            alertSuccess.dismiss(animated: true, completion: nil)
                                            self.performSegue(withIdentifier: "unwindToMap", sender: nil)
                                        }))
                                        self.present(alertSuccess, animated: true, completion: nil)
                                    } else {
                                        print("no image to delete \(error)")
                                        let alertSuccess = UIAlertController(title: "Success", message: "You have successfully deleted this Memorial and all of it's content", preferredStyle: .alert)
                                        alertSuccess.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                            alertSuccess.dismiss(animated: true, completion: nil)
                                            self.performSegue(withIdentifier: "unwindToMap", sender: nil)
                                        }))
                                        self.present(alertSuccess, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    let alertFailure = UIAlertController(title: "ERROR", message: "Sorry, there was an error while trying to delete this Memorial's stories, please check your internet connection  and try again", preferredStyle: .alert)
                    alertFailure.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        alertFailure.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alertFailure, animated: true, completion: nil)
                    print("Story document not deleted, ERROR")
                }
            }
        }
        alerController.addAction(delete)
        self.present(alerController, animated: true) {
            
        }
    }
    
    @IBAction func uploadVideoButtonWasTapped(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.mediaTypes = ["public.movie"]
            introVideoToBeCleared = false
            present(picker, animated: true, completion: nil)
        }
    }
    @IBAction func playVideo(_ sender: UIButton) {
        guard let safeVideoURL = self.videoURL else { return }
        playURLVideo(url: safeVideoURL)
//        guard let safeVideoURLAsString = self.videoURL?.absoluteString else { return }
//        guard let videoPath = Bundle.main.path(forResource: safeVideoURLAsString, ofType: "mp4") else {
//            debugPrint("video not found")
//            return
//        }
//        guard let url = URL(string: safeVideoURLString) else { return }
        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
//        let player = AVPlayer(url: url)
        
//        let player = AVPlayer(url: URL(fileURLWithPath: videoPath))
//               let playerController = AVPlayerViewController()
//               playerController.player = player
//               present(playerController, animated: true) {
//                   player.play()
//               }

        // Create a new AVPlayerViewController and pass it a reference to the player.
//        let controller = AVPlayerViewController()
//        controller.player = player
//
//        // Modally present the player and call the player's play() method when complete.
//        present(controller, animated: true) {
//            player.play()
//        }
    }
    
}
