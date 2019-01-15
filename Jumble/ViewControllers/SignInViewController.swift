//
//  ViewController.swift
//  Jumble
//
//  Created by David Lie-Tjauw on 11/1/18.
//  Copyright © 2018 Team Jumble. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {

    var userEmail:String = ""
    var userPassword:String = ""
    @IBOutlet var signInButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        emailTextField.layer.borderColor = UIColor.black.cgColor;
        passwordTextField.layer.borderColor = UIColor.black.cgColor;
        
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
//        self.signInButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        print("Show")
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        print("Hide")
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    @IBAction func updateUserEmail(_ sender: UITextField) {
        if let email = sender.text{
            self.userEmail = email
        }
        else{
            self.userEmail = ""
        }
    }
    @IBAction func updateUserPassword(_ sender: UITextField) {
        if let password = sender.text{
            self.userPassword = password
        }
        else{
            self.userPassword = ""
        }
    }
    
    func displaySignInErrorMsg(msg:String){
        let errorMsg = UIAlertController(title:"Error", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        errorMsg.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.default,handler:nil))
        self.present(errorMsg,animated:true,completion:nil)
    }
    
    func handleSignInError(err:NSError){
        if(err.code == 17009){
            self.displaySignInErrorMsg(msg:"The password is invalid or the user does not have a password")
        }
        else if(err.code == 17008){
            self.displaySignInErrorMsg(msg:"Please enter a valid email format")
        }
        else if(err.code == 17011){
            self.displaySignInErrorMsg(msg:"User Account does not exist")
        }
        else if(err.code == 17020){
            self.displaySignInErrorMsg(msg: "Please connect to WiFi");
        }
        else{
            self.displaySignInErrorMsg(msg: "Unhandled Error has Occurred \(err.code)")
        }
    }
    
    @IBAction func signInUser(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: self.userEmail, password: self.userPassword) { (user, error) in
            guard let userAuth = user else {
                self.handleSignInError(err: error! as NSError)
                return
            }
            let mainPage:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "JumbleTabBarController") as UIViewController

            self.present(mainPage, animated: true, completion: nil)


            
        }
    }
    


}

