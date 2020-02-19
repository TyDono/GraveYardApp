//
//  StoryImagesCollectionViewCell.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 2/7/20.
//  Copyright © 2020 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


class StoryImagesCollectionViewCell: UICollectionViewCell, UIImagePickerControllerDelegate {
    @IBOutlet weak var storyImages: UIImageView!
    
    var imageString: String?
    var graveProfileImage: GraveProfileImage?
    var graveProfileImages = [UIImage]()
    let storage = Storage.storage()
    
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let selectedImage = info[.originalImage] as? UIImage {
//                storyImages.image = selectedImage
//                graveProfileImages.append(selectedImage)
//                dismiss(animated: true, completion: nil)
//                self.storyImages.reloadInputViews()
//            }
//        }
//        
//        func getImages() {
//            if let imageStringId = self.imageString {
//                let storageRef = storage.reference()
//                let graveProfileImage = storageRef.child("graveProfileImages/\(imageStringId)")
//                graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
//                    guard let data = data else {return}
//                    guard let image = UIImage(data: data) else {return}
//                    self.storyImages.image = image
//                })
//            } else {
//                return
//            }
//        }
//        
//        func saveImageToFirebase(graveImagesURL: URL, completion: @escaping((_ success: Bool) -> ())) {
//            let databaseRef = Firestore.firestore().document("graveProfileImages/test123")
//            let userObjectImages = [
//                "imageURL": graveImagesURL.absoluteString
//            ] as [String:Any]
//            databaseRef.setData(userObjectImages) { (error) in
//                completion(error == nil)
//            }
//            print("SaveImageToFirebase has been saved!!!!!")
//        }
//    
//        struct PropertyKeys {
//            static let unwind = "unwindToGraveSegue"
//        }
//        
//        func uploadFirebaseImages(_ image: UIImage, completion: @escaping ((_ url: URL?) -> () )) {
//            let storageRef = Storage.storage().reference().child("graveProfileImages/\(self.imageString ?? "no Image Found")")
//            guard let imageData = image.jpegData(compressionQuality: 0.20) else { return }
//            let metaData = StorageMetadata()
//            metaData.contentType = "image/jpg"
//            storageRef.putData(imageData, metadata: metaData) { (metaData, error) in
//                if error == nil, metaData != nil {
//                    print("got grave image")
//                    storageRef.downloadURL(completion: { (url, error) in
//                        completion(url)
//                    })
//                } else {
//                    completion(nil)
//                }
//            }
//        }
    
}
