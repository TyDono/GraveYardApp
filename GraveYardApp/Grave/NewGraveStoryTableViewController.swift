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
    
    @IBOutlet weak var storyImage1: UIImageView!
    @IBOutlet weak var storyImage2: UIImageView!
    @IBOutlet weak var storyImage3: UIImageView!
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
    var storyImageId1: String? = ""
    var storyImageId2: String? = ""
    var storyImageId3: String? = ""
    let storage = Storage.storage()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storyTitleTextField.text = graveStoryTitleValue
        storyBodyTextView.text = graveStoryBodyTextValue
        chageTextColor()
        db = Firestore.firestore()
        
        getImage1()
        getImage2()
        getImage3()
    }
    
    // MARK: - Functions
    
//make 3 images for new/edit story. THIS LIMITS IT to only 3.  those r uploaded indivisually. then those are pulled down as an array an dpopulated in the actual story. they each have their own name which is storyId + 1, 2, or 3. that String is saved in an array. then to pull down images we use that array and pull them down. then each image will set as a var. those vars will then b epu tinto the array. like var 1 vasr 2 var 3. then array is var array = [var1, var2, var3]
    
    func chageTextColor() {
        tableView.separatorColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
    }
    
    func updateStoryData() {
        guard let creatorId: String = currentAuthID,
            let graveId: String = MapViewController.shared.currentGraveId,
            let storyId: String = currentGraveStoryId,
            let storyBodyText: String = storyBodyTextView.text,
            let storyTitle: String = storyTitleTextField.text,
            let storyImageId1: String = self.storyImageId1,
            let storyImageId2: String = self.storyImageId2,
            let storyImageId3: String = self.storyImageId3 else { return }
        
        let story = Story(creatorId: creatorId,
                          graveId: graveId,
                          storyId: storyId,
                          storyBodyText: storyBodyText,
                          storyTitle: storyTitle,
                          storyImageId1: storyImageId1,
                          storyImageId2: storyImageId2,
                          storyImageId3: storyImageId3)
        
        let storyRef = self.db.collection("stories")
        storyRef.document(String(story.storyId)).updateData(story.dictionary){ err in
            if let err = err {
                let alert1 = UIAlertController(title: "Not Saved", message: "Sorry, there was an error while trying to save your Story. Please try again.", preferredStyle: .alert)
                alert1.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alert1.dismiss(animated: true, completion: nil)
                }))
                self.present(alert1, animated: true, completion: nil)
                print(err)
            } else {
                self.performSegue(withIdentifier: "unwindtoGraveStoriesSegue", sender: nil)
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
                storyImages.append(selectedImage)
            case 2:
                storyImage2.image = selectedImage
                storyImages.append(selectedImage)
            case 3:
                storyImage3.image = selectedImage
                storyImages.append(selectedImage)
            default:
                print("")
            }
            dismiss(animated: true, completion: nil)
            self.storyImage1.reloadInputViews()
            self.storyImage2.reloadInputViews()
            self.storyImage3.reloadInputViews()
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
    
    func saveImageToFirebase(graveImagesURL: URL, completion: @escaping((_ success: Bool) -> ())) {
        let databaseRef = Firestore.firestore().document("storyImages/\(self.currentGraveStoryId ?? "no image")")
        let userObjectImages = [
            "imageURL": graveImagesURL.absoluteString
        ] as [String:Any]
        databaseRef.setData(userObjectImages) { (error) in
            completion(error == nil)
        }
        print("SaveImageToFirebase has been saved!!!!!")
    }
    
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

    
    // MARK: - Actions
    
    @IBAction func saveStoryBarButtonTapped(_ sender: UIBarButtonItem) {
        guard storyImage1.image != nil else { return }
        for image in storyImages {
            uploadFirebaseImage1(image) { (url) in
                guard let url = url else { return }
//                self.saveImageToFirebase(graveImagesURL: url, completion: { success in
//                    self.firebaseWrite(url: url.absoluteString)
//                })
            }
        }
        for image in storyImages {
            guard storyImage2.image != nil else { return }
            uploadFirebaseImage2(image) { (url) in
                guard let url = url else { return }
            }
        }
        for image in storyImages {
            guard storyImage3.image != nil else { return }
            uploadFirebaseImage3(image) { (url) in
                guard let url = url else { return }
            }
        }
        updateStoryData()
    }
    
    @IBAction func deleteStoryButtonTapped(_ sender: UIButton) {
        let alerController = UIAlertController(title: "WARNING!", message: "This will delete all of the information on this Story!", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alerController.addAction(cancel)
        let delete = UIAlertAction(title: "DELETE", style: .destructive) { _ in
            
            let userId = self.currentAuthID!
            let userRef = self.db.collection("stories")
            userRef.document(self.currentGraveStoryId ?? "no StoryId detected").delete(){ err in
                if err == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        moveToMap()
                    }
                } else {
                    let alert1 = UIAlertController(title: "ERROR", message: "Sorry, there was an error while trying to delete this story, please check your internet connection and try again", preferredStyle: .alert)
                    alert1.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        alert1.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert1, animated: true, completion: nil)
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
    
}

extension NewGraveStoryTableViewController {
    func getImage1() {
        if let imageStringId = self.storyImageId1 {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
                guard let data = data else {return}
                guard let image = UIImage(data: data) else {return}
                self.storyImage1.image = image
            })
        } else {
            return
        }
    }
    
    func uploadFirebaseImage1(_ image: UIImage, completion: @escaping ((_ url: URL?) -> () )) {
        let storageRef = Storage.storage().reference().child("storyImages/\(self.storyImageId1 ?? "no image found")")
        guard let imageData = image.jpegData(compressionQuality: 0.20) else { return }
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
            graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
                guard let data = data else {return}
                guard let image = UIImage(data: data) else {return}
                self.storyImage2.image = image
            })
        } else {
            return
        }
    }
    
    func uploadFirebaseImage2(_ image: UIImage, completion: @escaping ((_ url: URL?) -> () )) {
        let storageRef = Storage.storage().reference().child("storyImages/\(self.storyImageId2 ?? "no image found")")
        guard let imageData = image.jpegData(compressionQuality: 0.20) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            if error == nil, metaData != nil {
                print("got story images2")
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
            graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
                guard let data = data else {return}
                guard let image = UIImage(data: data) else {return}
                self.storyImage3.image = image
            })
        } else {
            return
        }
    }
    
    func uploadFirebaseImage3(_ image: UIImage, completion: @escaping ((_ url: URL?) -> () )) {
        let storageRef = Storage.storage().reference().child("storyImages/\(self.storyImageId3 ?? "no image found")")
        guard let imageData = image.jpegData(compressionQuality: 0.20) else { return }
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
    
}
