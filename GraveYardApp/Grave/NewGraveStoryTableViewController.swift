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
    var storyImageId1: String = ""
    var storyImageId2: String = ""
    var storyImageId3: String = ""
    let storage = Storage.storage()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storyTitleTextField.text = graveStoryTitleValue
        storyTitleTextField.text = graveStoryBodyTextValue
        chageTextColor()
        db = Firestore.firestore()
    }
    
    // MARK: - Functions
    
//make 3 images for new/edit story. THIS LIMITS IT to only 3.  those r uploaded indivisually. then those are pulled down as an array an dpopulated in the actual story. they each have their own name which is storyId + 1, 2, or 3. that String is saved in an array. then to pull down images we use that array and pull them down. then each image will set as a var. those vars will then b epu tinto the array. like var 1 vasr 2 var 3. then array is var array = [var1, var2, var3]
    
    func chageTextColor() {
        tableView.separatorColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
    }
    
    func updateStoryData() {
        guard let creatorId: String = currentAuthID else { return }
        guard let graveId: String = MapViewController.shared.currentGraveId else { return }
        guard let storyId: String = currentGraveStoryId else { return }
        guard let storyBodyText: String = storyBodyTextView.text else { return }
        guard let storyTitle: String = storyTitleTextField.text else { return }
        let storyImageId1: String = self.storyImageId1
        let storyImageId2: String = self.storyImageId2
        let storyImageId3: String = self.storyImageId3
        
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
            case 2:
                storyImage2.image = selectedImage
            case 3:
                storyImage3.image = selectedImage
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
    
    func uploadFirebaseImages(_ image: UIImage, completion: @escaping ((_ url: URL?) -> () )) {
        let storageRef = Storage.storage().reference().child("graveProfileImages/\(self.imageString ?? "no Image Found")")
        guard let imageData = image.jpegData(compressionQuality: 0.20) else { return }
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

    
    // MARK: - Actions
    
    @IBAction func saveStoryBarButtonTapped(_ sender: UIBarButtonItem) {
           //guard let unwrappedStoryImage = storyImage1.image else { return }
                for image in storyImages {
                    uploadFirebaseImages(image) { (url) in
                        print(url)
                        guard let url = url else { return }
        //                self.saveImageToFirebase(graveImagesURL: url, completion: { success in
        //                    self.firebaseWrite(url: url.absoluteString)
        //                })
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
                    //                    print("Logged Out Tapped")
                    //                    self.currentUser = nil
                    //                    self.userId = ""
                    //                    try! Auth.auth().signOut()
                    //                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    //                        moveToLogIn()
                    //                    }
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
