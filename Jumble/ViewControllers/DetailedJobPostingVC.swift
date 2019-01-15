//
//  DetailedJobPostingVC.swift
//  Jumble
//
//  Created by Emily Wiederhold on 11/17/18.
//  Copyright © 2018 Team Jumble. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class DetailedJobPostingVC: UIViewController {
    var jobDescription: String!;
    var jobName: String!;
    var location: String!;
    var pay: Double!;
    var time: String!;
    var user: String!;
    var firstName: String!;
    var lastName: String!;
    var userId:String!;
    var ownerId:String!;
    var hasIndicatedInterest:Bool!
    
    // first and lastname of user clicking the interested button
    var userFirstName:String!
    var userLastName:String!
    
    
    @IBOutlet var notInterestedButton: UIButton!
//    @IBOutlet var interestButton: UIButton!
    @IBOutlet var showUserInterestButton: UIButton!
    
    @IBOutlet var descriptionLabel: UITextView!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var payLabel: UILabel!
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var deleteJobPostingButton: UIButton!
    
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.checkIfUserAuthenticated()
        
        //firebase stuff
        ref = Database.database().reference()
        let currentUser = Auth.auth().currentUser
        self.userId = currentUser?.uid

        self.title = jobName;
        
        descriptionLabel.text = jobDescription!;
        locationLabel.text = location!;
        timeLabel.text = "\(time!) Hours";
        payLabel.text = "$\(String(format:"%.2f", pay!))";
        userLabel.text = "\(firstName!) \(lastName!)";
    }
//    @IBOutlet var showInterest: UIButton!
    @IBAction func showInterest(_ sender: UIButton) {
        
        // update jobs that user is interested in
        self.ref.child("users").child(self.userId).child("jobsInterestedIn").child(self.ownerId).setValue(true)
        
        //update job node with update list of people interested in this specific job
self.ref.child("jobPosts").child(self.ownerId).child("interestedUsers").child("\(userFirstName!)-\(userLastName!)-\(userId!)").setValue(true)
        self.notInterestedButton.isHidden = false
        self.showUserInterestButton.isHidden = true
        
    }
    @IBAction func revokeInterest(_ sender: UIButton) {
        
        // update jobs that user is interested in
        self.ref.child("users").child(self.userId).child("jobsInterestedIn").child(self.ownerId).removeValue(completionBlock: { (error, refer) in
            if error != nil {
               
            } else {
                self.notInterestedButton.isHidden = true
                self.showUserInterestButton.isHidden = false
               
            }
        })
        
        //update job node with update list of people interested in this specific job
    self.ref.child("jobPosts").child(self.ownerId).child("interestedUsers").child("\(userFirstName!)-\(userLastName!)-\(userId!)").removeValue()
    }
    
    @IBAction func deleteJobPostingPressed(_ sender: UIButton!) {
        // citation: https://stackoverflow.com/questions/42749130/how-to-delete-a-child-from-firebase-swift
        self.ref.child("jobPosts").child(jobName+"-"+self.userId).removeValue(completionBlock: { (error, refer) in
            if error != nil {
                //citation: https://learnappmaking.com/uialertcontroller-alerts-swift-how-to/
                let err = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
                err.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(err, animated: true)
                // end citation
            } else {
                //citation: https://learnappmaking.com/uialertcontroller-alerts-swift-how-to/
                let success = UIAlertController(title: "Success", message: "Your job has been deleted", preferredStyle: .alert)
                success.addAction(UIAlertAction(title: "Ok", style: .default, handler: {action in
                    if let navController = self.navigationController {
                        navController.popViewController(animated: true)
                    }
                }))
                self.present(success, animated: true)
                // end citation
            }
            //delete the job posting from firebase
        })
    }
    
    // if user is NOT signed in, then send them to SignInViewController
    func checkIfUserAuthenticated(){
        if Auth.auth().currentUser == nil {
            let mainPage:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNav") as UIViewController
            self.present(mainPage, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //if currently logged in user id matches user id of current job posting, show the button
        if(Auth.auth().currentUser?.uid == user) {
            deleteJobPostingButton.isHidden = false;
            
            // don't allow user to indicate interest on their own job posting
            self.notInterestedButton.isHidden = true
            self.showUserInterestButton.isHidden = true
        }
        //otherwise don't show the button
        else {
            deleteJobPostingButton.isHidden = true;
            if(self.hasIndicatedInterest!){
                self.notInterestedButton.isHidden = false
                self.showUserInterestButton.isHidden = true
            }
            else{
                self.notInterestedButton.isHidden = true
                self.showUserInterestButton.isHidden = false
            }

            
            
        }
        
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
