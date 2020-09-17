//
//  NewGraveStoryTableViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 11/7/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FirebaseStorage

class NewGraveStoryTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var deleteStoryButton: UIButton!
    @IBOutlet weak var imageLabel1: UILabel!
    @IBOutlet weak var imageLabel2: UILabel!
    @IBOutlet weak var imageLabel3: UILabel!
    @IBOutlet weak var imageLabel4: UILabel!
    @IBOutlet weak var imageLabel5: UILabel!
    @IBOutlet weak var imageLabel6: UILabel!
    @IBOutlet weak var storyImage1: UIImageView!
    @IBOutlet weak var storyImage2: UIImageView!
    @IBOutlet weak var storyImage3: UIImageView!
    @IBOutlet weak var storyImage4: UIImageView!
    @IBOutlet weak var storyImage5: UIImageView!
    @IBOutlet weak var storyImage6: UIImageView!
    @IBOutlet weak var storyTitleTextField: UITextField!
    @IBOutlet weak var storyBodyTextView: UITextView!
    
    // MARK: - Propeties
    
    var currentButtonTapped: Int = 0
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var currentGraveStoryId: String?
    var graveStoryTitleValue: String?
    var graveStoryBodyTextValue: String?
    var imageString: String?
    var storyImage: GraveProfileImage?
    var storyImages = [UIImage]()
    var storyImages1 = [UIImage]()
    var storyImages2 = [UIImage]()
    var storyImages3 = [UIImage]()
    var storyImages4 = [UIImage]()
    var storyImages5 = [UIImage]()
    var storyImages6 = [UIImage]()
    var storyImageId1: String? = ""
    var storyImageId2: String? = ""
    var storyImageId3: String? = ""
    var storyImageId4: String? = ""
    var storyImageId5: String? = ""
    var storyImageId6: String? = ""
    var storyImageStringArray: [String] = []
    var arrayOfStoryImageIDs: [String] = [] // idk wtf this is here
//    var storyCount: Int = 0
    var currentGraveId: String?
    let newDataCount: Double? = 0.0
    let storage = Storage.storage()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.deleteStoryButton.layer.cornerRadius = 10
        storyTitleTextField.text = graveStoryTitleValue
        storyBodyTextView.text = graveStoryBodyTextValue
        //chageTextColor()
        db = Firestore.firestore()
        
//        getImages()
        getImage1()
        getImage2()
        getImage3()
        getImage4()
        getImage5()
        getImage6()
    }
    
    // MARK: - Functions
    
    func updateDataStorage() {
        guard let currentId = currentAuthID else { return }
        let updateDataRef = self.db.collection("userProfile").document(currentId)
        updateDataRef.updateData([
            "dataCount": newDataCount
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func getGraveData() {
        let graveRef = self.db.collection("grave").whereField("graveId", isEqualTo: MapViewController.shared.currentGraveId!) // this should be the grave id that was tapped on
        graveRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    guard let arrayOfStoryImageIDs = document.data()["arrayOfStoryImageIDs"] as? [String] else { return }
                    self.arrayOfStoryImageIDs = arrayOfStoryImageIDs
                }
            }
        }
    }
    
    func updateArrayOfStoryImageIDs() {
        let arrayOfStoryImageIDs = self.arrayOfStoryImageIDs
        guard let currentGraveId = self.currentGraveId else { return }
        self.db.collection("grave").document(currentGraveId).updateData([
            "arrayOfStoryImageIDs": arrayOfStoryImageIDs
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
                let alert1 = UIAlertController(title: "Not Saved", message: "Sorry, there was an error while trying to save your Story. Please try again.", preferredStyle: .alert)
                alert1.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alert1.dismiss(animated: true, completion: nil)
                }))
                self.present(alert1, animated: true, completion: nil)
            } else {
                let alert2 = UIAlertController(title: "Saved", message: "You have successfully saved \(self.storyTitleTextField.text ?? "this story")", preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alert2.dismiss(animated: true, completion: nil)
                    self.performSegue(withIdentifier: "unwindtoGraveStoriesSegue", sender: nil)
                }))
                self.present(alert2, animated: true, completion: nil)
            }
        }
    }
    
    func chageTextColor() {
        tableView.separatorColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
    }
    
    func updateStoryData() {
        guard let creatorId: String = currentAuthID,
            let graveId: String = self.currentGraveId,
            let storyId: String = currentGraveStoryId,
            let storyBodyText: String = storyBodyTextView.text,
            let storyTitle: String = storyTitleTextField.text,
//            let storyImageArray: [String]? = [String](),
            let storyImageId1: String = self.storyImageId1,
            let storyImageId2: String = self.storyImageId2,
            let storyImageId3: String = self.storyImageId3,
            let storyImageId4: String = self.storyImageId4,
            let storyImageId5: String = self.storyImageId5,
            let storyImageId6: String = self.storyImageId6 else { return }
        let storyImageArray = [String]()
        
        let story = Story(creatorId: creatorId,
                          graveId: graveId,
                          storyId: storyId,
                          storyBodyText: storyBodyText,
                          storyTitle: storyTitle,
                          storyImageArray: storyImageArray,
                          storyImageId1: storyImageId1,
                          storyImageId2: storyImageId2,
                          storyImageId3: storyImageId3,
                          storyImageId4: storyImageId4,
                          storyImageId5: storyImageId5,
                          storyImageId6: storyImageId6)
        
        let storyRef = self.db.collection("stories")
        storyRef.document(String(story.storyId)).updateData(story.dictionary){ err in
            if let err = err {
                print(err)
            } else {
                self.updateArrayOfStoryImageIDs()
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            switch currentButtonTapped {
            case 1:
                storyImage1.image = selectedImage
                storyImages1.append(selectedImage)
            case 2:
                storyImage2.image = selectedImage
                storyImages2.append(selectedImage)
            case 3:
                storyImage3.image = selectedImage
                storyImages3.append(selectedImage)
            case 4:
                storyImage4.image = selectedImage
                storyImages4.append(selectedImage)
            case 5:
                storyImage5.image = selectedImage
                storyImages5.append(selectedImage)
            case 6:
                storyImage6.image = selectedImage
                storyImages6.append(selectedImage)
                
            default:
                print("")
            }
            dismiss(animated: true, completion: nil)
            self.storyImage1.reloadInputViews()
            self.storyImage2.reloadInputViews()
            self.storyImage3.reloadInputViews()
            self.storyImage4.reloadInputViews()
            self.storyImage5.reloadInputViews()
            self.storyImage6.reloadInputViews()
        }
    }
    
//    func getImages() {
//        if let imageStringId = self.imageString {
//            let storageRef = storage.reference()
//            let graveProfileImage = storageRef.child("graveProfileImages/\(imageStringId)")
//            graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
//                guard let data = data else {return}
//                guard let image = UIImage(data: data) else {return}
//                self.graveMainImage.image = image
//            })
//        } else {
//            return
//        }
//    }
    
//    func saveImageToFirebase(graveImagesURL: URL, completion: @escaping((_ success: Bool) -> ())) { // not being caled
//        let databaseRef = Firestore.firestore().document("storyImages/\(self.currentGraveStoryId ?? "no image")")
//        let userObjectImages = [
//            "imageURL": graveImagesURL.absoluteString
//        ] as [String:Any]
//        databaseRef.setData(userObjectImages) { (error) in
//            completion(error == nil)
//        }
//        print("SaveImageToFirebase has been saved!!!!!")
//    }
    
//    func uploadFirebaseImages(_ image: UIImage, completion: @escaping ((_ url: URL?) -> () )) {
//        let storageRef = Storage.storage().reference().child("storyImages/\(self.storyImageId1 ?? "no image found")")
//        guard let imageData = image.jpegData(compressionQuality: 0.20) else { return }
//        let metaData = StorageMetadata()
//        metaData.contentType = "image/jpg"
//        storageRef.putData(imageData, metadata: metaData) { (metaData, error) in
//            if error == nil, metaData != nil {
//                print("got story images")
//                storageRef.downloadURL(completion: { (url, error) in
//                    completion(url)
//                })
//            } else {
//                completion(nil)
//            }
//        }
//    }
    
    func deleteSelectStopryImage(imageName: String) {
        self.storage.reference().child("storyImages/\(imageName)").delete { (err) in
            if err == nil {
                //no error
            } else {
                print(err)
            }
        }
    }
    
    func deletedStoryImages() {
        guard let storyImageId1 = self.storyImageId1,
            let storyImageId2 = self.storyImageId2,
            let storyImageId3 = self.storyImageId3,
            let storyImageId4 = self.storyImageId4,
            let storyImageId5 = self.storyImageId5,
            let storyImageId6 = self.storyImageId6 else { return }
        
        self.storyImageStringArray = [storyImageId1, storyImageId2, storyImageId3, storyImageId4, storyImageId5, storyImageId6]
        for i in self.storyImageStringArray {
            self.storage.reference().child("storyImages/\(i)").delete { (err) in
                if err == nil {
                    // no error
                } else {
                    // this might be called since they might not have images to be deleted. also called if they dont have an image 2 or 3. it will still delete the images that do exist.
                    print(err as Any)
                }
            }
        }
    }
    
    func deleteOneFromStoryCount() {
        guard let currentGrave = MapViewController.shared.currentGraveId else { return }
        print(GraveTableViewController.currentGraveStoryCount)
        GraveTableViewController.currentGraveStoryCount -= 1
        print(GraveTableViewController.currentGraveStoryCount)
        db.collection("grave").document(currentGrave).updateData([
            "storyCount": GraveTableViewController.currentGraveStoryCount
        ]) { err in
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "unwindtoGraveStoriesSegue", let graveStoriesTVC = segue.destination as? GraveStoriesTableViewController {
//            graveStoriesTVC.storyCount = self.currentGraveStoryCount
//        }
//    }
    
    // MARK: - Actions
    
    @IBAction func saveStoryBarButtonTapped(_ sender: UIBarButtonItem) {
        let clearedImage = UIImage(named: "tyler_mountain")
//        for storyImage in storyImages {
//
//            print(storyImage)
//            uploadFirebaseImage(storyImage) { (url) in
//                print("\(url) uploaded successfully")
//            }
//        }
        
        if storyImage1.image != nil {
            if storyImage1.image == clearedImage {
                guard let safeStoryImageId = self.storyImageId1 else { return }
                deleteSelectStopryImage(imageName: safeStoryImageId)
            }
            for image in storyImages1 {
                uploadFirebaseImage1(image) { (url) in
//                    guard let url = url else { return }
                    //                self.saveImageToFirebase(graveImagesURL: url, completion: { success in
                    //                    self.firebaseWrite(url: url.absoluteString)
                    //                })
                }
            }
        }
        if storyImage2.image != nil {
            if storyImage2.image == clearedImage {
                guard let safeStoryImageId = self.storyImageId2 else { return }
                deleteSelectStopryImage(imageName: safeStoryImageId)
            }
            for image in storyImages2 {
                uploadFirebaseImage2(image) { (url) in
//                    guard let url = url else { return }
                }
            }
        }

        if storyImage3.image != nil {
            if storyImage3.image == clearedImage {
                guard let safeStoryImageId = self.storyImageId3 else { return }
                deleteSelectStopryImage(imageName: safeStoryImageId)
            }
            for image in storyImages3 {
                uploadFirebaseImage3(image) { (url) in
//                    guard let url = url else { return }
                }
            }
        }
        
        if storyImage4.image != nil {
            if storyImage4.image == clearedImage {
                guard let safeStoryImageId = self.storyImageId4 else { return }
                deleteSelectStopryImage(imageName: safeStoryImageId)
            }
            for image in storyImages4 {
                uploadFirebaseImage4(image) { (url) in
//                    guard let url = url else { return }
                }
            }
        }
        
        if storyImage5.image != nil {
            if storyImage5.image == clearedImage {
                guard let safeStoryImageId = self.storyImageId5 else { return }
                deleteSelectStopryImage(imageName: safeStoryImageId)
            }
            for image in storyImages5 {
                uploadFirebaseImage5(image) { (url) in
//                    guard let url = url else { return }
                }
            }
        }
        
        if storyImage6.image != nil {
            if storyImage6.image == clearedImage {
                guard let safeStoryImageId = self.storyImageId6 else { return }
                deleteSelectStopryImage(imageName: safeStoryImageId)
            }
            for image in storyImages6 {
                uploadFirebaseImage6(image) { (url) in
//                    guard let url = url else { return }
                }
            }
        }
        updateStoryData()
    }
    
    @IBAction func deleteStoryButtonTapped(_ sender: UIButton) {
        let alerController = UIAlertController(title: "WARNING!", message: "This will delete all of the information on this Story!", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alerController.addAction(cancel)
        let delete = UIAlertAction(title: "DELETE", style: .destructive) { _ in
            
            let userRef = self.db.collection("stories")
            userRef.document(self.currentGraveStoryId ?? "no StoryId detected").delete(){ err in
                if err == nil {
                    self.deleteOneFromStoryCount()
                    self.deletedStoryImages()
                    let alert1 = UIAlertController(title: "Success", message: "This Story and all of it's contents have been successfully deleted", preferredStyle: .alert)
                    alert1.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        alert1.dismiss(animated: true, completion: nil)
                        self.performSegue(withIdentifier: "unwindtoGraveStoriesSegue", sender: nil)
                    }))
                    self.present(alert1, animated: true, completion: nil)
                } else {
                    let alert2 = UIAlertController(title: "ERROR", message: "Sorry, there was an error while trying to delete this story, please check your internet connection and try again", preferredStyle: .alert)
                    alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        alert2.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert2, animated: true, completion: nil)
                    print("document not deleted, ERROR")
                }
            }
        }
        alerController.addAction(delete)
        self.present(alerController, animated: true) {
        }
    }
    
    @IBAction func storyImage1ButtonTapped(_ sender: UIButton) {
        currentButtonTapped = 1
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func storyImage2ButtonTapped(_ sender: Any) {
        currentButtonTapped = 2
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func storyImage3ButtonTapped(_ sender: UIButton) {
        currentButtonTapped = 3
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func storyImage4ButtonTapped(_ sender: UIButton) {
        currentButtonTapped = 4
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    @IBAction func storyImage5ButtonTapped(_ sender: Any) {
        currentButtonTapped = 5
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    @IBAction func storyImage6ButtonTapped(_ sender: UIButton) {
        currentButtonTapped = 6
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func clearStoryImage1ButtonTapped(_ sender: UIButton) {
        let clearedImage = UIImage(named: "tyler_mountain")
        storyImage1.image = clearedImage
        self.tableView.reloadData()
    }
    
    @IBAction func clearStoryImage2ButtonTapped(_ sender: UIButton) {
        let clearedImage = UIImage(named: "tyler_mountain")
        storyImage2.image = clearedImage
        self.tableView.reloadData()
    }
    
    @IBAction func clearStoryImage3ButtonTapped(_ sender: UIButton) {
        let clearedImage = UIImage(named: "tyler_mountain")
        storyImage3.image = clearedImage
        self.tableView.reloadData()
    }
    
    @IBAction func clearStoryImage4ButtonTapped(_ sender: UIButton) {
        let clearedImage = UIImage(named: "tyler_mountain")
        storyImage4.image = clearedImage
        self.tableView.reloadData()
    }
    
    @IBAction func clearStoryImage5ButtonTapped(_ sender: UIButton) {
        let clearedImage = UIImage(named: "tyler_mountain")
        storyImage5.image = clearedImage
        self.tableView.reloadData()
    }
    
    @IBAction func clearStoryImage6ButtonTapped(_ sender: UIButton) {
        let clearedImage = UIImage(named: "tyler_mountain")
        storyImage6.image = clearedImage
        self.tableView.reloadData()
    }
    
}

extension NewGraveStoryTableViewController {
    
//    func getImages() {
//        print(storyImageStringArray)
//        for imageStringId in storyImageStringArray {
//            let storageRef = storage.reference()
//            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
//            graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
//                guard let data = data else {return}
//                guard let image = UIImage(data: data) else {return}
//
//                self.storyImage3.image = image
//                self.imageLabel3.text = nil
//            })
//        }
//    }
    
//    func uploadFirebaseImage(_ image: UIImage, completion: @escaping ((_ url: URL?) -> () )) { // now the only one needed test
//        for imageStringId in storyImageStringArray {
//            let storageRef = Storage.storage().reference().child("storyImages/\(imageStringId)")
//            guard let imageData = image.jpegData(compressionQuality: 0.10) else { return }
//            let metaData = StorageMetadata()
//            metaData.contentType = "image/jpg"
//            storageRef.putData(imageData, metadata: metaData) { (metaData, error) in
//                if error == nil, metaData != nil {
//                    print("got story images")
//                    storageRef.downloadURL(completion: { (url, error) in
//                        completion(url)
//                    })
//                } else {
//                    completion(nil)
//                }
//            }
//        }
//    }
    
    func getImage1() {
        if let imageStringId = self.storyImageId1 {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (5000000), completion:  { (data, err) in
                guard let data = data else { return }
                guard let image = UIImage(data: data) else { return }
                self.storyImage1.image = image
//                self.imageLabel1.text = nil
            })
        } else {
            return
        }
    }
    
    func uploadFirebaseImage1(_ image: UIImage, completion: @escaping ((_ url: URL?) -> () )) {
        guard let storyImageId1 = self.storyImageId1 else { return }
        let storageRef = Storage.storage().reference().child("storyImages/\(storyImageId1)")
        guard let imageData = image.jpegData(compressionQuality: 0.10) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            if error == nil, metaData != nil {
                print("got story images1")
                storageRef.downloadURL(completion: { (url, error) in
                    completion(url)
                })
            } else {
                completion(nil)
            }
        }
    }
    
    func getImage2() {
        if let imageStringId = self.storyImageId2 {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (5000000), completion:  { (data, err) in
                guard let data = data else { return }
                guard let image = UIImage(data: data) else { return }
                self.storyImage2.image = image
//                self.imageLabel2.text = nil
            })
        } else {
            return
        }
    }
    
    func uploadFirebaseImage2(_ image: UIImage, completion: @escaping ((_ url: URL?) -> () )) {
        guard let storyImageId2 = self.storyImageId2 else { return }
        let storageRef = Storage.storage().reference().child("storyImages/\(storyImageId2)")
        guard let imageData = image.jpegData(compressionQuality: 0.10) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            if error == nil, metaData != nil {
                print("got story images1")
                storageRef.downloadURL(completion: { (url, error) in
                    completion(url)
                })
            } else {
                completion(nil)
            }
        }
    }
    
    func getImage3() {
        if let imageStringId = self.storyImageId3 {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (5000000), completion:  { (data, err) in
                guard let data = data else { return }
                guard let image = UIImage(data: data) else { return }
                self.storyImage3.image = image
//                self.imageLabel3.text = nil
            })
        } else {
            return
        }
    }
    
    func uploadFirebaseImage3(_ image: UIImage, completion: @escaping ((_ url: URL?) -> () )) {
        guard let storyImageId3 = self.storyImageId3 else { return }
        let storageRef = Storage.storage().reference().child("storyImages/\(storyImageId3)")
        guard let imageData = image.jpegData(compressionQuality: 0.10) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            if error == nil, metaData != nil {
                print("got story images3")
                storageRef.downloadURL(completion: { (url, error) in
                    completion(url)
                })
            } else {
                completion(nil)
            }
        }
    }
    
    func getImage4() {
        if let imageStringId = self.storyImageId4 {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (5000000), completion:  { (data, err) in
                guard let data = data else { return }
                guard let image = UIImage(data: data) else { return }
                self.storyImage4.image = image
//                self.imageLabel1.text = nil
            })
        } else {
            return
        }
    }
    
    func uploadFirebaseImage4(_ image: UIImage, completion: @escaping ((_ url: URL?) -> () )) {
        guard let storyImageId = self.storyImageId4 else { return }
        let storageRef = Storage.storage().reference().child("storyImages/\(storyImageId)")
        guard let imageData = image.jpegData(compressionQuality: 0.10) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            if error == nil, metaData != nil {
                print("got story images1")
                storageRef.downloadURL(completion: { (url, error) in
                    completion(url)
                })
            } else {
                completion(nil)
            }
        }
    }
    
    func getImage5() {
        if let imageStringId = self.storyImageId5 {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (5000000), completion:  { (data, err) in
                guard let data = data else { return }
                guard let image = UIImage(data: data) else { return }
                self.storyImage5.image = image
//                self.imageLabel1.text = nil
            })
        } else {
            return
        }
    }
    
    func uploadFirebaseImage5(_ image: UIImage, completion: @escaping ((_ url: URL?) -> () )) {
        guard let storyImageId = self.storyImageId5 else { return }
        let storageRef = Storage.storage().reference().child("storyImages/\(storyImageId)")
        guard let imageData = image.jpegData(compressionQuality: 0.10) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            if error == nil, metaData != nil {
                print("got story images1")
                storageRef.downloadURL(completion: { (url, error) in
                    completion(url)
                })
            } else {
                completion(nil)
            }
        }
    }
    
    func getImage6() {
        if let imageStringId = self.storyImageId6 {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (5000000), completion:  { (data, err) in
                guard let data = data else { return }
                guard let image = UIImage(data: data) else { return }
                self.storyImage6.image = image
//                self.imageLabel1.text = nil
            })
        } else {
            return
        }
    }
    
    func uploadFirebaseImage6(_ image: UIImage, completion: @escaping ((_ url: URL?) -> () )) {
        guard let storyImageId = self.storyImageId6 else { return }
        let storageRef = Storage.storage().reference().child("storyImages/\(storyImageId)")
        guard let imageData = image.jpegData(compressionQuality: 0.10) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            if error == nil, metaData != nil {
                print("got story images1")
                storageRef.downloadURL(completion: { (url, error) in
                    completion(url)
                })
            } else {
                completion(nil)
            }
        }
    }
    
}
