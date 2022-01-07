//
//  feedViewController.swift
//  firebasefeed
//


import UIKit
import FirebaseStorage
import Firebase
import FirebaseFirestore
import OpalImagePicker
import Photos

struct feedData  {
    var userId : String
    var postid : String
    var imageUrl : [String]
    var likecount : Int
    var isliked : Bool
    
}


class feedViewController: UIViewController {
    
    // let db = Storage.storage()
    
    var feedArray = [feedData]()
    
    var myTableView: UITableView!
    
    
    let db = Firestore.firestore()
    
    var totalPost : Int = 0
    
    var items = [feedData]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // Do any additional setup after loading the view.
        setNavBar()
        
        setTableView()
        
        fetchAllfeeds()
        
        
        // AddLike(postId : "1641472014.666072")
        
        
    }
    
    
    func setTableView(){
        myTableView = UITableView(frame: CGRect(x: 0, y: getStatusBarHeight()+44, width: view.frame.width, height: view.frame.height-getStatusBarHeight()-44))
        myTableView.register(feedTableViewCell.self, forCellReuseIdentifier: "feedTableViewCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.rowHeight = UITableView.automaticDimension
        myTableView.estimatedRowHeight = 100
        
        self.view.addSubview(myTableView)
        
        
        
    }
    
    
    func fetchAllfeeds() {
        self.feedArray.removeAll()
        
        let db = Firestore.firestore()
        
        view.activityStartAnimating(activityColor: .darkGray, backgroundColor: .clear)
        
        db.collection("feeds").order(by: "postid", descending: true).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                  
                    self.totalPost = querySnapshot?.count ?? 0
                    
                    
                    
                    let postid = document.get("postid") as! String
                    let userName = document.get("userId") as! String
                    let userImage = document.get("imageUrl") as! NSArray
                    let likecount = document.get("likecount") as! Int
                    
                    let isliked = document.get("isliked") as! Bool
                    
                    let feed = feedData(userId: userName, postid:postid, imageUrl: userImage as! [String], likecount: likecount,isliked: isliked)
                    
                    NSLog(feed.postid)
                    
                    self.feedArray.append(feed)
                    
                    
                }
            }
            
            self.myTableView.reloadData()
            self.view.activityStopAnimating()
        }
        
    }
    
    
    
    
    
    func setNavBar(){
        
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: getStatusBarHeight(), width: view.frame.size.width, height: 44))
        
        view.addSubview(navBar)
        
        let navItem = UINavigationItem(title: "TEST")
        
        let backButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addPostButtonClicked))
        backButtonItem.tintColor = UIColor.label
        navItem.rightBarButtonItem = backButtonItem
        navBar.setItems([navItem], animated: false)
        
    }
    
    
    
    
    
    @objc func addPostButtonClicked(){
        
        let imagePicker = OpalImagePickerController()
        presentOpalImagePickerController(imagePicker, animated: true,
                                         select: { (assets) in
                                            //Select Assets
                                            
    UploadImages.saveImages(imagesArray: self.getAssetThumbnail(assets: assets, completion: {
                                                
    //self.view.activityStartAnimating(activityColor: .darkGray, backgroundColor: .clear)
        
      DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                                                    self.fetchAllfeeds()
                                                    imagePicker.dismiss(animated: true, completion: nil)
                                                }
                                            }))
                                            
                                            
                                         }, cancel: {
                                            //Cancel
                                            
                                            imagePicker.dismiss(animated: true, completion: nil)
                                         })
        
        
        
    }
    
    
    //Like post
    func AddLike(postId : String){
        
        let db = Firestore.firestore()
        
        
        db.collection("feeds").document(postId).updateData([
            
            "isliked" : true
            
        ]) { err in
            if let err = err {
                print("Error: \(err)")
            } else {
                print("added successfully!")
            }}
        
        db.collection("feeds").document(postId).updateData(["likecount": FieldValue.increment(Int64(1))])
        
        fetchAllfeeds()
    }
    
    //Dislike post
    
    func DeleteLike(postId : String){
        
        let db = Firestore.firestore()
        
        
        db.collection("feeds").document(postId).updateData([
            
            "isliked" : false
            
        ]) { err in
            if let err = err {
                print("Error: \(err)")
            } else {
                print("added successfully!")
            }}
        
        db.collection("feeds").document(postId).updateData(["likecount": FieldValue.increment(Int64(-1))])
        
        fetchAllfeeds()
        
    }
    
    
    //MARK: Convert array of PHAsset to UIImages
    func getAssetThumbnail(assets: [PHAsset], completion: () -> ()) -> [UIImage] {
        var arrayOfImages = [UIImage]()
        for asset in assets {
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            var image = UIImage()
            option.isSynchronous = true
            manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                image = result!
                arrayOfImages.append(image)
            })
        }
        completion()
        return arrayOfImages
    }
    
}

extension feedViewController : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedTableViewCell", for: indexPath) as!  feedTableViewCell
        
        let models =  self.feedArray[indexPath.row]
        
        cell.setUp(model: models)
        
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
        
        
        return cell
    }
    
    
    @objc func likeButtonClicked(sender : AnyObject){
        
        if self.feedArray[sender.tag].isliked == true{
            DeleteLike(postId : self.feedArray[sender.tag].postid)
        }
        else{
            AddLike(postId: self.feedArray[sender.tag].postid)
        }
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 320
        
    }
    
}
