//
//  InterestedUserInformationViewController.swift
//  Jumble
//
//  Created by David Lie-Tjauw on 12/1/18.
//  Copyright © 2018 Team Jumble. All rights reserved.
//

import UIKit
import Firebase

class InterestedUserInformationViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    var userDescription:String!
    var userImageURL:String!
    var userEmail:String!
    var userSkills:[String] = []
    var userFullName:String!
    var userId:String!
    
    var ref: DatabaseReference!

    
    @IBOutlet var profileLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet var userSkillsTableView: UITableView!
    @IBOutlet var userDescriptionTextBox: UITextView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userEmailLabel: UILabel!
    @IBOutlet var newUserImageProfile: UIImageView!
    @IBOutlet var userImageProfile: UIImageView!
    var tempProfileImg:UIImage = UIImage(named: "default_profile_picture")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkIfUserAuthenticated()
        ref = Database.database().reference()
        self.profileLoadingIndicator.layer.zPosition = 999;
        self.profileLoadingIndicator.startAnimating()
        setupSkillsTableView()
        self.userSkillsTableView.reloadData()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.checkIfUserAuthenticated()
        setUserData()
        self.userSkillsTableView.reloadData()
    }
    
    
    
    func setupSkillsTableView(){
        self.userSkillsTableView.dataSource = self
        self.userSkillsTableView.delegate = self
        self.userSkillsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.userSkillsTableView.isEditing = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Tableview count of interested user skills: \(self.userSkills.count)")
        return self.userSkills.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel!.text = self.userSkills[indexPath.row]
        return cell
    }
    
    func setUserData(){
        
        self.userSkills = []
        self.userNameLabel.text = self.userFullName
        
        self.profileLoadingIndicator.startAnimating()

        self.ref.child("users").child(self.userId).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            for (key, value) in postDict {
                if(key == "description"){
                    self.userDescription = value as! String
                    self.userDescriptionTextBox.text = self.userDescription
                }
                else if(key == "email"){
                    self.userEmail = value as! String
                    self.userEmailLabel.text = self.userEmail
                }
                else if(key == "skills"){
                    for (key2, _) in value as! NSDictionary {
                        self.userSkills.append(key2 as! String)
                    }
                    
                }
                else if(key == "profileImageURL"){
                    self.userImageURL = value as! String
                }
            }
            self.userSkillsTableView.reloadData()

            DispatchQueue.global(qos: .userInitiated).async{
                self.getUserImg()
                DispatchQueue.main.async {
                    self.profileLoadingIndicator.stopAnimating()
                    self.displayUserImg()
                }
            }
    
            
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUserImg(){
        if let profileImageUrl = self.userImageURL{
            let url = URL(string: profileImageUrl)
            let data = try? Data(contentsOf: url!)
            self.tempProfileImg = UIImage(data:data!)!
            print("being called in image")
        }
        else{
            self.tempProfileImg = UIImage(named: "default_profile_picture")!
        }
    }
    
    func displayUserImg(){
//        self.userImageProfile.image = self.tempProfileImg
        self.newUserImageProfile.image = self.tempProfileImg
        print("IMAGE HAS BEEN SET")
    }
    
    // if user is NOT signed in, then send them to SignInViewController
    func checkIfUserAuthenticated(){
        if Auth.auth().currentUser == nil {
            let mainPage:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNav") as UIViewController
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
