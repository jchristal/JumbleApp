//
//  SignUpViewController.swift
//  Jumble
//
//  Created by David Lie-Tjauw on 11/1/18.
//  Copyright © 2018 Team Jumble. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class SignUpViewController: UIViewController {

    @IBOutlet var signUpButton: UIButton!
    
    @IBOutlet var firstNameOutlet: UITextField!
    @IBOutlet var lastNameOutlet: UITextField!
    @IBOutlet var emailOutlet: UITextField!
    @IBOutlet var passwordOutlet: UITextField!
    @IBOutlet var confirmPasswordOutlet: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var userEmailField:String = ""
    var userPasswordField:String = ""
    var checkUserPasswordField:String = ""
    var userFirstName:String = ""
    var userLastName:String = ""
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        // create reference to Firebase Database
        ref = Database.database().reference()
        
        firstNameOutlet.addTarget(self, action: #selector(setButtonState), for: UIControlEvents.editingChanged)
        lastNameOutlet.addTarget(self, action: #selector(setButtonState), for: UIControlEvents.editingChanged)
        emailOutlet.addTarget(self, action: #selector(setButtonState), for: UIControlEvents.editingChanged)
        passwordOutlet.addTarget(self, action: #selector(setButtonState), for: UIControlEvents.editingChanged)
        confirmPasswordOutlet.addTarget(self, action: #selector(setButtonState), for: UIControlEvents.editingChanged)
    }
    
    
    // Disable the button if all the fields are not filled in OR the password is not matched
    @objc func setButtonState(){
        if(userEmailField.isEmpty || userPasswordField.isEmpty || userFirstName.isEmpty || userLastName.isEmpty || checkUserPasswordField.isEmpty || (userPasswordField != checkUserPasswordField)){
            //Disable Sign-Up Button
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor(red: 253/255, green: 210/255, blue: 138/255, alpha: 1);
        }
        else{
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor(red: 221/255, green: 240/255, blue: 255/255, alpha: 1);
        }
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
    
    @IBAction func listenToUserFirstName(_ sender: UITextField) {
        if let firstName = sender.text{
            //remove hyphen
            let newFirstName = firstName.replacingOccurrences(of: "-", with: "")
            self.userFirstName = newFirstName
        }
        else{
            self.userFirstName = ""
        }
    }
    
    @IBAction func listenToUserLastName(_ sender: UITextField) {
        if let lastName = sender.text{
            //remove hyphen
            let newLastName = lastName.replacingOccurrences(of: "-", with: "")
            self.userLastName = newLastName
        }
        else{
            self.userLastName = ""
        }
    }
    
    @IBAction func listenToUserEmailField(_ sender: UITextField) {
        if let email = sender.text{
            self.userEmailField = email
        }
        else{
            self.userEmailField = ""
        }
    }
    
    @IBAction func listenToUserPasswordField(_ sender: UITextField) {
        if let password = sender.text{
            self.userPasswordField = password
        }
        else{
            self.userPasswordField = ""
        }
    }
    
    
    @IBAction func listenToUserConfirmPassword(_ sender: UITextField) {
        if let checkPassword = sender.text{
            self.checkUserPasswordField = checkPassword
        }
        else{
            self.checkUserPasswordField = ""
        }
    }
    
    func displayErrorMsg(msg:String){
        let errorMsg = UIAlertController(title:"Error", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        errorMsg.addAction(UIAlertAction(title:"Ok",style: UIAlertActionStyle.default,handler:nil))
        self.present(errorMsg,animated:true,completion:nil)
    }
    
    func handleErrorMsg(err:NSError){
        if(err.code == 17026){
             displayErrorMsg(msg: "The password must be 6 characters long or more")
        }
        else if(err.code == 17008){
            displayErrorMsg(msg: "Please enter a valid email address")
        }
        else if(err.code == 17007){
            displayErrorMsg(msg: "The email address is already in use by another account")
        }
        else if(err.code == 17020){
            displayErrorMsg(msg: "Network error has occurred")
        }
        else{
            displayErrorMsg(msg: "An Error has Occurred")
        }
    }
    
    // Initialize the User Profile with First name, last name, and email
    func setUserInfo(userId:String){
        self.ref.child("users").child(userId).setValue(["firstName": self.userFirstName, "lastName":self.userLastName, "email":self.userEmailField])
    }
    
    @IBAction func signUpUser(_ sender: Any) {
        Auth.auth().createUser(withEmail: self.userEmailField, password: self.userPasswordField) { (authResult, error) in
            guard let user = authResult?.user else {
                self.handleErrorMsg(err: error! as NSError)
                return
            }
            self.setUserInfo(userId: user.uid)
//            let mainPage:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainThing") as UIViewController
//            self.present(mainPage, animated: true, completion: nil)
            let mainPage:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "JumbleTabBarController") as UIViewController
            self.present(mainPage, animated: true, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
