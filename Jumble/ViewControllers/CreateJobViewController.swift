//
//  CreateJobViewController.swift
//  Jumble
//
//  Created by David Lie-Tjauw on 11/5/18.
//  Copyright © 2018 Team Jumble. All rights reserved.
//

import UIKit
import Firebase

class CreateJobViewController: UIViewController {
    
    // Entry Fields
    @IBOutlet var jobNameField: UITextField!
    @IBOutlet var locationField: UITextField!
    @IBOutlet var estimatedTime: UITextField!
    @IBOutlet var payField: UITextField!
    @IBOutlet var jobDescriptionView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Job Posting Details
    var userId: String!
    var jobName: String!
    var location: String!
    var pay: Float!
    var time: String!
    var jobDescription: String!
    var userFirstName:String = ""
    var userLastName:String = ""
    
    var currentUnit:String = ""
    
    var ref: DatabaseReference!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.checkIfUserAuthenticated()
        self.userId = Auth.auth().currentUser?.uid
        ref = Database.database().reference()
        self.getFullName()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //view will appear
    override func viewDidAppear(_ animated: Bool) {
        self.checkIfUserAuthenticated()
    }
    
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.checkIfUserAuthenticated()
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
    
    @IBAction func jobNameChange(_ sender: Any) {
        if let name = jobNameField.text{
            // remove hyphen
            let newName = name.replacingOccurrences(of: "-", with: "")
            self.jobName = newName
        }
        else{
            self.jobName = ""
        }
    }
    @IBAction func locationChange(_ sender: Any) {
        if let loc = locationField.text{
            self.location = loc
        }
        else {
            self.location = ""
        }
    }
    @IBAction func timeChange(_ sender: Any) {
        if let length = estimatedTime.text {
            if(Float(length) != nil){
                self.time = length
            }
            else{
                self.time=""
                estimatedTime.text = ""
            }
        }
        else{
            self.time = ""
        }
    }
    @IBAction func payChange(_ sender: Any) {
        if let money = payField.text {
            if(Float(money) != nil){
                self.pay = (money as NSString).floatValue
            }
            else{
                self.pay=0
                payField.text = ""
            }
        }
        else{
            self.pay = 0
        }
    }
    
    @IBAction func postJob(_ sender: UIButton) {
        self.view.endEditing(true)
        if(isFilledOut()){
            //citation: https://stackoverflow.com/questions/24070450/how-to-get-the-current-time-as-datetime
            let date = Date()
            // end citation
            
            if let description = jobDescriptionView.text{
                self.jobDescription = description
            }
            else {
                self.jobDescription = ""
            }
            self.ref.child("jobPosts").child("\(jobName!)-\(self.userId!)").setValue(["jobName": self.jobName, "location": self.location, "pay": self.pay, "time": self.time + " " + self.currentUnit, "jobDescription": self.jobDescription, "user": self.userId,"timestamp":"\(date)", "firstName": self.userFirstName, "lastName":self.userLastName])
            
            // Reset detail variables
            self.jobName = ""
            self.location = ""
            self.time = ""
            self.jobDescription = ""
            self.pay = 0
            
            // Reset field
            jobDescriptionView.text = ""
            jobNameField.text = ""
            estimatedTime.text = ""
            payField.text = ""
            locationField.text = ""
            //citation: https://learnappmaking.com/uialertcontroller-alerts-swift-how-to/
            let success = UIAlertController(title: "Success", message: "Your job has been posted", preferredStyle: .alert)
            success.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(success, animated: true)
            // end citation
        }
        else{
            //citation: https://learnappmaking.com/uialertcontroller-alerts-swift-how-to/
            let err = UIAlertController(title: "Error", message: "Please fill out all inputs", preferredStyle: .alert)
            err.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(err, animated: true)
            // end citation
        }
        
    }
    
    // check if all fields are filled out
    func isFilledOut()->Bool{
        return (jobDescriptionView.text != "") && ( jobNameField.text != "") && (estimatedTime.text != "") && (payField.text != "") && (locationField.text != "")
    }
    
    // if user is NOT signed in, then send them to SignInViewController
    func checkIfUserAuthenticated(){
        if Auth.auth().currentUser == nil {
            let mainPage:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNav") as UIViewController
            self.present(mainPage, animated: true, completion: nil)
        }
    }
    
    // get user's first and last name to add to new job posting
    func getFullName(){
        self.ref.child("users").child(self.userId).observeSingleEvent(of: .value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            // set user name label
            self.userFirstName = postDict["firstName"] as? String ?? ""
            self.userLastName = postDict["lastName"] as? String ?? ""
        })
    }
    
//    @IBAction func selectTimeInterval(_ sender: UIButton) {
//        let ac = UIAlertController(title: "Choose a Time Interval…", message: nil, preferredStyle: .actionSheet)
//        ac.addAction(UIAlertAction(title: "Minutes", style: .default, handler: changeFilter))
//        ac.addAction(UIAlertAction(title: "Hours", style: .default, handler: changeFilter))
//        ac.addAction(UIAlertAction(title: "Days", style: .default, handler: changeFilter))
//         ac.addAction(UIAlertAction(title: "Weeks", style: .default, handler: changeFilter))
//        ac.addAction(UIAlertAction(title: "Months", style: .default, handler: changeFilter))
//        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: changeFilter))
//        present(ac, animated: true, completion: nil)
//    }
//    @IBOutlet var unitsLabel: UILabel!
    
//    @objc func changeFilter(action: UIAlertAction!){
//        switch(action.title!){
//        case "Minutes":
//            self.unitsLabel.text = "Minutes"
//            self.currentUnit = "Minutes"
//            break
//        case "Hours":
//            self.unitsLabel.text = "Hours"
//            self.currentUnit = "Hours"
//            break
//        case "Days":
//            self.unitsLabel.text = "Days"
//            self.currentUnit = "Days"
//            break
//        case "Weeks":
//            self.unitsLabel.text = "Weeks"
//            self.currentUnit = "Weeks"
//            break
//        case "Months":
//            self.unitsLabel.text = "Months"
//            self.currentUnit = "Months"
//            break
//        default:
//            self.unitsLabel.text = "undef."
//            break
//        }
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
