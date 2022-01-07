//
//  ViewController.swift
//  firebasefeed
//
import UIKit
import GoogleSignIn
import Firebase

class ViewController: UIViewController {
    
    
  var googleButton: GIDSignInButton!
    
    let signInConfig = GIDConfiguration.init(clientID: "819161391202-217309p68gvlimultor4kbjp159e65h8.apps.googleusercontent.com")
    
   

   

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        //GIDSignIn.sharedInstance.uiDelegate = self
               
        googleButton = GIDSignInButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 45))
        googleButton.center = view.center
        googleButton.style = GIDSignInButtonStyle.standard
        googleButton.addTarget(self, action: #selector(googleClicked), for: .touchUpInside)
        
        view.addSubview(googleButton)
        
    
        
        
    }
   
//    override func viewDidAppear(_ animated: Bool) {
//        openfeedVC()
//    }

    
    @objc func googleClicked(){
        GIDSignIn.sharedInstance.signIn(  with:signInConfig , presenting:self) { user, error in
           guard error == nil else { return }
           guard let user = user else { return }

           // Your user is signed in!
            print(user.profile?.name)
            print(user.profile?.imageURL(withDimension: 150))
            
            defaults.setValue(user.userID, forKey: ProjectModelKeys.userId)
            
            self.openfeedVC()
            
       }
        
     
    
    }
    
    func openfeedVC(){
        
        let feedVC = feedViewController()
        feedVC.modalPresentationStyle = .fullScreen
        present(feedVC, animated: false, completion: nil)
   
        
    }
   
}

