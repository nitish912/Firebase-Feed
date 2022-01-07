//
//  imageHandler.swift
//  firebasefeed
//



import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore

class UploadImages {
    
    static var uploadedImageUrlsArray = [String]()
    
    static func saveImages(imagesArray : [UIImage]){
        
        Auth.auth().signInAnonymously() { (user, error) in
            //let isAnonymous = user!.isAnonymous  // true
            //let uid = user!.uid
            if error != nil{
                print("save image error",error)
                return
            }
            guard let uid = user?.user.uid else{
                return
            }
            
            uploadImages(userId: uid,imagesArray : imagesArray){ (uploadedImageUrlsArray) in
                print("uploadedImageUrlsArray: \(uploadedImageUrlsArray)")
            }
        }
    }
    
    
    static func uploadImages(userId: String, imagesArray : [UIImage]?, completionHandler: @escaping  ([String]) -> ()){
        var storage =  Storage.storage()
        
       
        var uploadCount = 0
        let imagesCount = imagesArray?.count
        
        for image in imagesArray  ?? []  {
            
            let imageName = NSUUID().uuidString // Unique string to reference image
            
            //Create storage reference for image
            let storageRef = storage.reference().child("\(userId)").child("\(imageName).png") ?? nil
            
            
            guard let myImage = image as? UIImage else{
                return
            }
            guard let uplodaData = myImage.pngData() else{
                return
            }
            
            // Upload image to firebase
            
            
            guard let uploadTask =   storageRef?.putData(uplodaData, metadata: nil, completion: { (metaData, error) in
                storageRef?.downloadURL(completion: { (url, error) in
                    if let urlText = url?.absoluteString {
                        
                        uploadedImageUrlsArray.append(url?.absoluteString ?? "")
                    
                        uploadCount += 1
                    }
                    print("Number of images successfully uploaded: \(uploadCount)")
                    if uploadCount == imagesCount{
                        NSLog("All Images are uploaded successfully, uploadedImageUrlsArray: \(uploadedImageUrlsArray)")
                        completionHandler(uploadedImageUrlsArray )
                        saveDataInDatabase()
                    }
                })
            }) else { return  }
            
            observeUploadTaskFailureCases(uploadTask : uploadTask)
        }
    }
    
   
    
    static func observeUploadTaskFailureCases(uploadTask : StorageUploadTask){
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    NSLog("File doesn't exist")
                    break
                case .unauthorized:
                    NSLog("User doesn't have permission to access file")
                    break
                case .cancelled:
                    NSLog("User canceled the upload")
                    break
                    
                case .unknown:
                    NSLog("Unknown error occurred, inspect the server response")
                    break
                default:
                    NSLog("A separate error occurred, This is a good place to retry the upload.")
                    break
                }
            }
        }
    }
    
    
   static func saveDataInDatabase(){
        Firestore.firestore()
            .collection("feeds")
            .document("\(Date().millisecondsSince1970)")
            .setData([
                "postid" : "\(Date().millisecondsSince1970)",
                "imageUrl": uploadedImageUrlsArray ,
                "userId": defaults.string(forKey: ProjectModelKeys.userId)!,
                "likecount": 0,
                "isliked" : false
            ]) { [ self] err in
                guard self != nil else { return }
                if let err = err {
                    print("err ... \(err)")
             
                }
                else {
                    print("saved ok")
                 
                }
        }
    }
    
    
    
}
