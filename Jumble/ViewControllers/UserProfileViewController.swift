//
//  UserProfileViewController.swift
//  Jumble
//
//  Created by David Lie-Tjauw on 11/5/18.
//  Copyright © 2018 Team Jumble. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,  UITableViewDelegate, UITableViewDataSource {
    
    var skillsArray:[String] = []

    //outlets
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var skillsTableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var skillsInput: UITextField!
    @IBOutlet weak var addSkillButtonOutlet: UIButton!
    @IBOutlet var plsWork: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var tempProfileImg:UIImage = UIImage(named: "default_profile_picture")!
    
    var isUserDataSet:Bool = false
    
    // Firebase Storage Reference
    var ref: DatabaseReference!
    
    // Create a root reference to Google Storage (used for storing user profile image)
    let storage = Storage.storage()
    
    // User Details
    var userEmail:String!
    var userId:String!
    var userFirstName:String!
    var userLastName:String!
    var userDescription:String!
    var userProfileImageURL:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.checkIfUserAuthenticated()
        changePhotoButton.isHidden = true
        skillsInput.isHidden = true
        addSkillButtonOutlet.isHidden = true
        setupSkillsTableView()
        skillsTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.loadingIndicator.layer.zPosition = 999;
//        self.plsWork.layer.zPosition = 999;


        let currentUser = Auth.auth().currentUser
        self.userEmail = currentUser?.email
        self.userId = currentUser?.uid
        
        // initialize reference to Firebase Database
        ref = Database.database().reference()
        self.setUserData()
//        setupSkillsTableView()

    }
    //view will appear
    override func viewWillAppear(_ animated: Bool) {
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
    
    func setupSkillsTableView() {
        self.skillsTableView.dataSource = self
        self.skillsTableView.delegate = self
        self.skillsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.skillsTableView.isEditing = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return skillsArray.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel!.text = skillsArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            removeSkillFromFirebase(skillName: skillsArray[indexPath.row])
            skillsArray.remove(at: indexPath.row)
            skillsTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
            return .delete
        }
        
        return .none
    }
    
    //add skill
    @IBAction func addSkillButton(_ sender: UIButton) {
        insertNewSkill()
    }
    
    func insertNewSkill() {
        if skillsInput.text != "" {
            if let newSkillText = skillsInput.text {
                skillsArray.append(newSkillText)
                addSkillToFirebase(skillName: newSkillText)
                skillsInput.text = ""
                let indexPath = IndexPath(row: skillsArray.count - 1, section: 0)
                //          let indexPath = IndexPath(row: skillsArray.count , section: 0)
                
                skillsTableView.beginUpdates()
                skillsTableView.insertRows(at: [indexPath], with: .automatic)
                skillsTableView.endUpdates()
                view.endEditing(true)
            }
        }
        
    }
    
    // once the user clicks 'Add', then add skill to firebase
    func addSkillToFirebase(skillName:String){
        self.ref.child("users/\(self.userId!)/skills").child(skillName).setValue(true)
    }
    
    // if user deletes skill, remove skill from firebase
    func removeSkillFromFirebase(skillName:String){
        self.ref.child("users/\(self.userId!)/skills").child(skillName).removeValue();
    }
    
    //in edit mode
    var inEditMode:Bool = false
    @IBAction func editProfileButton(_ sender: UIButton) {
        if(!self.loadingIndicator.isAnimating){

        inEditMode = !inEditMode
        //edit button clicked
        if inEditMode {
            editButton.setTitle("Submit", for: UIControlState.normal)
            descriptionTextView.isEditable = true
            descriptionTextView.backgroundColor = UIColor.lightGray
            changePhotoButton.isHidden = false
            skillsInput.isHidden = false
            addSkillButtonOutlet.isHidden = false
            skillsTableView.isEditing = true
//            skillsTableView
        }
        //submit button clicked
        else {
            self.loadingIndicator.startAnimating()
            editButton.setTitle("Edit", for: UIControlState.normal)
            descriptionTextView.isEditable = false
            descriptionTextView.backgroundColor = UIColor.white
            changePhotoButton.isHidden = true
            skillsInput.isHidden = true
            addSkillButtonOutlet.isHidden = true
            skillsTableView.isEditing = false
//            skillsTableView.setEditing(false, animated: false);
            self.view.endEditing(true)
            //These 3 variables need to be saved to the database
            
            // save description text
            let descriptionText: String = descriptionTextView.text
            self.ref.child("users/\(self.userId!)/description").setValue(descriptionText)
            
            
            let profilePicture:UIImage = profilePictureView.image!
            let storageRef = storage.reference()
            let profileImageRef = storageRef.child("userProfileImages/\(self.userId!)")
            let imageData: NSData = UIImagePNGRepresentation(profilePicture)! as NSData
            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = profileImageRef.putData(imageData as Data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print("error occurred: \(String(describing: error))")
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                // You can also access to download URL after upload.
                profileImageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        print("error occurred: \(String(describing: error))")
                        return
                    }
                    self.ref.child("users/\(self.userId!)/profileImageURL").setValue(downloadURL.absoluteString)
                    
                    print("DONE CHANGING PHOTO =============================================")
                    self.loadingIndicator.stopAnimating()

                }
                
            }
        }
        }
    }
    
    func getUserImg(){
        if let profileImageUrl = self.userProfileImageURL{
            let url = URL(string: profileImageUrl)
            let data = try? Data(contentsOf: url!)
            self.tempProfileImg = UIImage(data:data!)!
        }
        else{
            self.tempProfileImg = UIImage(named: "default_profile_picture")!
        }
    }
    
    func setUserData(){
            // get user data from Firebase Database
        self.loadingIndicator.startAnimating()
        self.ref.child("users").child(self.userId).observeSingleEvent(of: .value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]

            // set user name label
            self.userFirstName = postDict["firstName"] as? String ?? ""
            self.userLastName = postDict["lastName"] as? String ?? ""
            self.fullNameLabel.text = self.userFirstName + " " + self.userLastName
            
            // set user email
            self.emailLabel.text = self.userEmail
            
            // set user description
            self.userDescription = postDict["description"] as? String ?? ""
            
            // set user profile image
            self.userProfileImageURL = postDict["profileImageURL"] as? String ?? nil
                
            // set user skills
            let allUserSkills = postDict["skills"] as? NSDictionary
            if let thingy = allUserSkills{
                for (key,value) in thingy{
                    self.skillsArray.append(key as! String)
                }
            }
                
            // refresh skills table view after grabbing skills data from firebase
            self.skillsTableView.reloadData()
                
            DispatchQueue.global(qos: .userInitiated).async{
                    self.getUserImg()
                    DispatchQueue.main.async {
                        self.loadingIndicator.stopAnimating()
                        self.displayUserData()
                    }
                }
                self.displayUserData()
        })
    }
    
    func displayUserData(){
        self.emailLabel.text = self.userEmail
        self.descriptionTextView.text = self.userDescription
        self.profilePictureView.image = self.tempProfileImg
    }
    //change photo
    @IBAction func changePhotoButtonClicked(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //sets profile picture
        profilePictureView.image = image
        picker.dismiss(animated: true, completion: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        
        if(!self.loadingIndicator.isAnimating){
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            self.checkIfUserAuthenticated()
        }
       
        
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
