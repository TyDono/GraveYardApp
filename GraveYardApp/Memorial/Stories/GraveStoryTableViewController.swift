//
//  GraveStoryTableViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 11/7/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class GraveStoryTableViewController: UITableViewController {
    
    // MARK: - Outlets
    

    @IBOutlet weak var justOneImageOnly: UIImageView!
    @IBOutlet weak var textStoryCell: UITableViewCell!
    @IBOutlet weak var imagesStoryCell: UITableViewCell!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var rightArrowButton: UIButton!
    @IBOutlet weak var leftArrowButton: UIButton!
    @IBOutlet weak var imageCounterLabel: UILabel!
    @IBOutlet weak var storyBodyTextView: UITextView!
    @IBOutlet weak var storyImagesScrollView: UIScrollView!
    @IBOutlet weak var storyTitle: UILabel!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    @IBOutlet var reportPopOver: UIView!
    @IBOutlet weak var reportCommentsTextView: UITextView!
    
    // MARK: - Propeties
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var graveStoryId: String?
    var creatorId: String?
    let storage = Storage.storage()
    var graveStorytitleValue: String?
    var graveStoryBodyBioValue: String?
    let screenHeight = UIScreen.main.bounds.height
    var storyUIImage1: UIImage?
    var storyUIImage2: UIImage?
    var storyUIImage3: UIImage?
    var storyUIImage4: UIImage?
    var storyUIImage5: UIImage?
    var storyUIImage6: UIImage?
    var storyImagesArray: [UIImage?] = []
    var storyImageId1: String? = "1"
    var storyImageId2: String? = "2"
    var storyImageId3: String? = "3"
    var storyImageId4: String? = "4"
    var storyImageId5: String? = "5"
    var storyImageId6: String? = "6"
    var storyImageIdArray: [String] = []
    var currentGraveId: String?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storyImagesScrollView.frame = view.frame
        //chageTextColor()
        db = Firestore.firestore()
        storyTitle.text = graveStorytitleValue
        storyBodyTextView.text = graveStoryBodyBioValue
        checkForCreatorId()
        storyImagesScrollView.delegate = self
        self.reportButton.layer.cornerRadius = 10
        justOneImageOnly.isHidden = true
        storyTitle.font = storyTitle.font.bold
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.getImage1()
        }
        
    }
    
    // MARK: - Functions
    
    //every slide is around 414
    func changeImageLabelCounter() {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            switch storyImagesArray.count {
            case 0:
                self.imageCounterLabel.text = ""
                self.rightArrowButton.isHidden = true
                self.leftArrowButton.isHidden = true
            case 1:
                self.imageCounterLabel.text = ""
                self.rightArrowButton.isHidden = true
                self.leftArrowButton.isHidden = true
                
            case 2:
                switch storyImagesScrollView.contentOffset.x {
                case -300.0...512.0:
                    self.imageCounterLabel.text = "1/2"
                    self.leftArrowButton.isHidden = true
                    self.rightArrowButton.isHidden = false
                case 113.0...514.0:
                    self.imageCounterLabel.text = "2/2"
                    self.rightArrowButton.isHidden = true
                    self.leftArrowButton.isHidden = false
                default:
                    self.imageCounterLabel.text = ""
                }
            case 3:
                switch storyImagesScrollView.contentOffset.x {
                case -300.0...512.0:
                    self.imageCounterLabel.text = "1/3"
                    self.leftArrowButton.isHidden = true
                    self.rightArrowButton.isHidden = false
                case 513.0...1536.0: // 414 is centered in 614 is half way out
                    self.imageCounterLabel.text = "2/3"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 613.0...928.0: //828 is centered in
                    self.imageCounterLabel.text = "3/3"
                    self.rightArrowButton.isHidden = true
                    self.leftArrowButton.isHidden = false
                default:
                    self.imageCounterLabel.text = ""
                }
            case 4:
                switch storyImagesScrollView.contentOffset.x {
                case -300.0...512.0:
                    self.imageCounterLabel.text = "1/4"
                    self.leftArrowButton.isHidden = true
                    self.rightArrowButton.isHidden = false
                case 513.0...1536.0: // 414 is centered in 614 is half way out
                    self.imageCounterLabel.text = "2/4"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 613.0...928.0: //828 is centered in
                    self.imageCounterLabel.text = "3/4"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 929.0...1452.0:
                    self.imageCounterLabel.text = "4/4"
                    self.rightArrowButton.isHidden = true
                    self.leftArrowButton.isHidden = false
                default:
                    self.imageCounterLabel.text = ""
                }
            case 5:
                switch storyImagesScrollView.contentOffset.x {
                case -300.0...512.0:
                    self.imageCounterLabel.text = "1/5"
                    self.leftArrowButton.isHidden = true
                    self.rightArrowButton.isHidden = false
                case 513.0...1536.0: // 414 is centered in 614 is half way out
                    self.imageCounterLabel.text = "2/5"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 613.0...928.0: //828 is centered in
                    self.imageCounterLabel.text = "3/5"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 929.0...1352.0:
                    self.imageCounterLabel.text = "4/5"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 1353.0...1876.0:
                    self.imageCounterLabel.text = "5/5"
                    self.rightArrowButton.isHidden = true
                    self.leftArrowButton.isHidden = false
                default:
                    self.imageCounterLabel.text = ""
                    self.imageCounterLabel.text = ""
                }
            case 6:
                switch storyImagesScrollView.contentOffset.x {
                case -300.0...512.0:
                    self.imageCounterLabel.text = "1/6"
                    self.leftArrowButton.isHidden = true
                    self.rightArrowButton.isHidden = false
                case 513.0...1536.0: // 414 is centered in 614 is half way out
                    self.imageCounterLabel.text = "2/6"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 1537.0...2112.0: //828 is centered in
                    self.imageCounterLabel.text = "3/6"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 2113.0...3072.0:
                    self.imageCounterLabel.text = "4/6"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 3073.0...4608.0:
                    self.imageCounterLabel.text = "5/6"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 4609.0...6544.0:
                    self.imageCounterLabel.text = "6/6"
                    self.rightArrowButton.isHidden = true
                    self.leftArrowButton.isHidden = false
                default:
                    self.imageCounterLabel.text = ""
                    self.imageCounterLabel.text = ""
                }
            default:
                self.imageCounterLabel.text = ""
            }
        } else {
            
            switch storyImagesArray.count {
            case 0:
                self.imageCounterLabel.text = ""
                self.rightArrowButton.isHidden = true
                self.leftArrowButton.isHidden = true
            case 1:
                self.imageCounterLabel.text = ""
                self.rightArrowButton.isHidden = true
                self.leftArrowButton.isHidden = true
                
            case 2:
                switch storyImagesScrollView.contentOffset.x {
                case -100.0...112.0:
                    self.imageCounterLabel.text = "1/2"
                    self.leftArrowButton.isHidden = true
                    self.rightArrowButton.isHidden = false
                case 113.0...514.0:
                    self.imageCounterLabel.text = "2/2"
                    self.rightArrowButton.isHidden = true
                    self.leftArrowButton.isHidden = false
                default:
                    self.imageCounterLabel.text = ""
                }
            case 3:
                switch storyImagesScrollView.contentOffset.x {
                case -100.0...112.0:
                    self.imageCounterLabel.text = "1/3"
                    self.leftArrowButton.isHidden = true
                    self.rightArrowButton.isHidden = false
                case 113.0...614.0: // 414 is centered in 614 is half way out
                    self.imageCounterLabel.text = "2/3"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 613.0...928.0: //828 is centered in
                    self.imageCounterLabel.text = "3/3"
                    self.rightArrowButton.isHidden = true
                    self.leftArrowButton.isHidden = false
                default:
                    self.imageCounterLabel.text = ""
                }
            case 4:
                switch storyImagesScrollView.contentOffset.x {
                case -100.0...112.0:
                    self.imageCounterLabel.text = "1/4"
                    self.leftArrowButton.isHidden = true
                    self.rightArrowButton.isHidden = false
                case 113.0...614.0: // 414 is centered in 614 is half way out
                    self.imageCounterLabel.text = "2/4"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 613.0...928.0: //828 is centered in
                    self.imageCounterLabel.text = "3/4"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 929.0...1452.0:
                    self.imageCounterLabel.text = "4/4"
                    self.rightArrowButton.isHidden = true
                    self.leftArrowButton.isHidden = false
                default:
                    self.imageCounterLabel.text = ""
                }
            case 5:
                switch storyImagesScrollView.contentOffset.x {
                case -100.0...112.0:
                    self.imageCounterLabel.text = "1/5"
                    self.leftArrowButton.isHidden = true
                    self.rightArrowButton.isHidden = false
                case 113.0...614.0: // 414 is centered in 614 is half way out
                    self.imageCounterLabel.text = "2/5"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 613.0...928.0: //828 is centered in
                    self.imageCounterLabel.text = "3/5"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 929.0...1352.0:
                    self.imageCounterLabel.text = "4/5"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 1353.0...1876.0:
                    self.imageCounterLabel.text = "5/5"
                    self.rightArrowButton.isHidden = true
                    self.leftArrowButton.isHidden = false
                default:
                    self.imageCounterLabel.text = ""
                    self.imageCounterLabel.text = ""
                }
            case 6:
                switch storyImagesScrollView.contentOffset.x {
                case -100.0...112.0:
                    self.imageCounterLabel.text = "1/6"
                    self.leftArrowButton.isHidden = true
                    self.rightArrowButton.isHidden = false
                case 113.0...614.0: // 414 is centered in 614 is half way out
                    self.imageCounterLabel.text = "2/6"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 613.0...928.0: //828 is centered in
                    self.imageCounterLabel.text = "3/6"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 929.0...1352.0:
                    self.imageCounterLabel.text = "4/6"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 1353.0...1776.0:
                    self.imageCounterLabel.text = "5/6"
                    self.rightArrowButton.isHidden = false
                    self.leftArrowButton.isHidden = false
                case 1777.0...2300.0:
                    self.imageCounterLabel.text = "6/6"
                    self.rightArrowButton.isHidden = true
                    self.leftArrowButton.isHidden = false
                default:
                    self.imageCounterLabel.text = ""
                    self.imageCounterLabel.text = ""
                }
            default:
                self.imageCounterLabel.text = ""
            }
        }
    }
    
    override func scrollViewDidScroll(_ storyImagesScrollView: UIScrollView) {
        changeImageLabelCounter()
    }
    
    //count is 0 coz it gets it b4 we get any images
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat
        if self.storyImagesArray.count == 0 {
            if indexPath.row == 0 {
                height = 800.0
            } else {
                height = 0.0
            }
        } else {
            height = 340
        }
        return height
    }
    
    func JustOneImage() {
        justOneImageOnly.isHidden = false
        self.justOneImageOnly.image = storyUIImage1
    }
    
    func setUpScrollView() {
        for i in 0..<storyImagesArray.count {
            let imageView = UIImageView()
            imageView.image = storyImagesArray[i]
            let xPosition = self.view.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: self.storyImagesScrollView.frame.width, height: self.storyImagesScrollView.frame.height)
            imageView.contentMode = .scaleAspectFit
            storyImagesScrollView.contentSize.width = storyImagesScrollView.frame.width * CGFloat(i + 1)
            storyImagesScrollView.addSubview(imageView)
        }
    }
    
    func chageTextColor() {
        tableView.separatorColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editGraveStorySegue", let editGraveStoryTVC = segue.destination as? NewGraveStoryTableViewController {
            editGraveStoryTVC.currentGraveId = self.currentGraveId
            editGraveStoryTVC.currentGraveStoryId = graveStoryId
            editGraveStoryTVC.graveStoryTitleValue = storyTitle.text
            editGraveStoryTVC.graveStoryBodyTextValue = storyBodyTextView.text
//            guard let safeStoryImageId1 = self.storyImageId1,
//                let safeStoryImageId2 = self.storyImageId2,
//                let safeStoryImageId3 = self.storyImageId3,
//                let safeStoryImageId4 = self.storyImageId4,
//                let safeStoryImageId5 = self.storyImageId5,
//                let safeStoryImageId6 = self.storyImageId6 else { return }
            editGraveStoryTVC.storyImageId1 = storyImageId1
            editGraveStoryTVC.storyImageId2 = storyImageId2
            editGraveStoryTVC.storyImageId3 = storyImageId3
            editGraveStoryTVC.storyImageId4 = storyImageId4
            editGraveStoryTVC.storyImageId5 = storyImageId5
            editGraveStoryTVC.storyImageId6 = storyImageId6
//            editGraveStoryTVC.storyImageStringArray = [storyImageId1, storyImageId2, storyImageId3, storyImageId4, storyImageId5, storyImageId6]
        }
    }
    
    func createReportData() {
        let userReportId: String = UUID().uuidString
        guard let currentAuthID = self.currentAuthID else {
            var alertStyle = UIAlertController.Style.alert
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                alertStyle = UIAlertController.Style.alert
            }
            let reportGraveFailAlert = UIAlertController(title: "Failed to report", message: "You must be sign in to send a report", preferredStyle: alertStyle)
            let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
            reportGraveFailAlert.addAction(dismiss)
            self.present(reportGraveFailAlert, animated: true, completion: nil)
            return
        }
        let userReport = UserReport(reporterCreatorId: currentAuthID, reason: reportCommentsTextView.text, creatorId: creatorId!, graveId: "", storyId: graveStoryId!)
        let userReportRef = self.db.collection("userReports")
        userReportRef.document(userReportId).setData(userReport.dictionary) { err in
            if let err = err {
                var alertStyle = UIAlertController.Style.alert
                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    alertStyle = UIAlertController.Style.alert
                }
                let reportGraveFailAlert = UIAlertController(title: "Failed to report", message: "Your device failed to send the report. Please make sure you are logged in with an internet connection.", preferredStyle: alertStyle)
                let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
                reportGraveFailAlert.addAction(dismiss)
                self.present(reportGraveFailAlert, animated: true, completion: nil)
                print(err)
            } else {
                var alertStyle = UIAlertController.Style.alert
                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    alertStyle = UIAlertController.Style.alert
                }
                let graveReportAlertSucceed = UIAlertController(title: "Thank you!", message: "Your report has been received, thank you for your help.", preferredStyle: alertStyle)
                let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
                graveReportAlertSucceed.addAction(dismiss)
                self.removeReportPopOverAnimate()
                self.present(graveReportAlertSucceed, animated: true, completion: nil)
            }
        }
    }
    
    func checkForCreatorId() {
        if currentAuthID == creatorId {
            rightBarButtonItem.title = "Edit"
        } else {
            rightBarButtonItem.title = "Report"
        }
    }
    
    func showReportPopOverAnimate() {
        self.reportPopOver.center = self.view.center
        self.reportPopOver.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.reportPopOver.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.reportPopOver.alpha = 1.0
            self.reportPopOver.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeReportPopOverAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.reportPopOver.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.reportPopOver.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.reportPopOver.removeFromSuperview()
                }
        });
    }
    
    // MARK: - Actions
    
    @IBAction func reportButtonTapped(_ sender: UIButton) {
        createReportData()
    }
    
    @IBAction func closeReportPopUp(_ sender: UIButton) {
        removeReportPopOverAnimate()
    }
    
    @IBAction func editStoryBarButtonTapped(_ sender: UIBarButtonItem) {
        if currentAuthID == self.creatorId {
            performSegue(withIdentifier: "editGraveStorySegue", sender: nil)
        } else {
            self.view.addSubview(reportPopOver)
            showReportPopOverAnimate()
        }
    }
    
    @IBAction func leftArrowImageSlideButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func rightArrowImageSlideButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func unwindtoGraveStory(_ sender: UIStoryboardSegue) {}
    
}

extension GraveStoryTableViewController {
    //it's a mess :/  just placeholder for the time being due to time constraint and a fo rloop doesnt brin them back in the order needed
    func getImage1() {
        if let imageStringId = self.storyImageId1 {
            let storageRef1 = storage.reference()
            let graveProfileImage = storageRef1.child("storyImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (5000000), completion:  { (data, err) in
                guard let data = data else { return }
                guard let image = UIImage(data: data) else {
                    self.getImage2()
                    return
                }
                //                self.storyImagesArray.append(image)
                self.storyUIImage1 = image
                //                self.storyImage1.image = image // images exists but storyimage1 is nil
                guard let storyImage = self.storyUIImage1 else { return }
                //                guard let storyImage: UIImage = self.storyImage1 else { return }
                self.storyImagesArray.append(storyImage)
                self.JustOneImage()
                self.setUpScrollView()
                self.getImage2()
                self.tableView.reloadData()
            })
        } else {
            getImage2()
        }
    }

    func getImage2() {
        if let imageStringId = self.storyImageId2 {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (5000000), completion:  { (data, err) in
                guard let data = data else { return }
                guard let image = UIImage(data: data) else {
                    self.getImage3()
                    return
                }
                self.storyUIImage2 = image
                guard let storyImage = self.storyUIImage2 else { return }
                self.storyImagesArray.append(storyImage)
                self.setUpScrollView()
                self.changeImageLabelCounter()
                self.justOneImageOnly.isHidden = true
                self.getImage3()
                self.tableView.reloadData()
            })
        } else {
            self.getImage3()
        }
    }

    func getImage3() {
        if let imageStringId = self.storyImageId3 {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (5000000), completion:  { (data, err) in
                guard let data = data else {
                    self.getImage4()
                    return
                }
                guard let image = UIImage(data: data) else { return }
                self.storyUIImage3 = image
                guard let storyImage = self.storyUIImage3 else { return }
                self.storyImagesArray.append(storyImage)
                self.setUpScrollView()
                self.changeImageLabelCounter()
                self.getImage4()
                self.tableView.reloadData()
            })
        } else {
            self.getImage4()
        }
    }
    
    func getImage4() {
        if let imageStringId = self.storyImageId4 {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (5000000), completion:  { (data, err) in
                guard let data = data else {
                    self.getImage5()
                    return
                }
                guard let image = UIImage(data: data) else { return }
                self.storyUIImage4 = image
                guard let storyImage = self.storyUIImage4 else { return }
                self.storyImagesArray.append(storyImage)
                self.setUpScrollView()
                self.changeImageLabelCounter()
                self.getImage5()
                self.tableView.reloadData()
            })
        } else {
            self.getImage5()
        }
    }
    
    func getImage5() {
        if let imageStringId = self.storyImageId5 {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (5000000), completion:  { (data, err) in
                guard let data = data else {
                    self.getImage5()
                    return
                }
                guard let image = UIImage(data: data) else {return}
                self.storyUIImage5 = image
                guard let storyImage = self.storyUIImage5 else { return }
                self.storyImagesArray.append(storyImage)
                self.setUpScrollView()
                self.changeImageLabelCounter()
                self.getImage6()
                self.tableView.reloadData()
            })
        } else {
            self.getImage6()
        }
    }
    
    func getImage6() {
        if let imageStringId = self.storyImageId6 {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (5000000), completion:  { (data, err) in
                guard let data = data else { return }
                guard let image = UIImage(data: data) else { return }
                self.storyUIImage6 = image
                guard let storyImage = self.storyUIImage6 else { return }
                self.storyImagesArray.append(storyImage)
                self.setUpScrollView()
                self.changeImageLabelCounter()
                self.tableView.reloadData()
            })
        } else {
            return
        }
    }
    
//    func getImages() {
//        guard let storyImageId1 = self.storyImageId1,
//            let storyImageId2 = self.storyImageId2,
//            let storyImageId3 = self.storyImageId3,
//            let storyImageId4 = self.storyImageId4,
//            let storyImageId5 = self.storyImageId5,
//            let storyImageId6 = self.storyImageId6 else { return }
//
//        self.storyImageIdArray = [storyImageId1, storyImageId2, storyImageId3, storyImageId4, storyImageId5, storyImageId6]
//        for imageStringId in self.storyImageIdArray {
//            let storageRef = storage.reference()
//            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
//            graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
//                guard let data = data else {return}
//                guard let image = UIImage(data: data) else { return }
//                self.storyImagesArray.append(image)
//                self.setUpScrollView()
//                self.changeImageLabelCounter()
//
//            })
//        }
//    }
    
}
