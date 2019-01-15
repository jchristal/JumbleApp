//
//  YourJobsViewController.swift
//  Jumble
//
//  Created by David Lie-Tjauw on 11/30/18.
//  Copyright © 2018 Team Jumble. All rights reserved.
//

import UIKit
import Firebase

class YourJobsViewController: UITableViewController {
    
    var userPostedJobs:[String] = []

    var ref: DatabaseReference!
    var userId:String!

    @IBOutlet var userJobsTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        checkIfUserAuthenticated()
        let currentUser = Auth.auth().currentUser
        self.userId = currentUser?.uid

        print("Your userid is: \(userId)")
        print("YOUR JOBS HAS LOADED")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.userJobsTable.dataSource = self
        self.userJobsTable.delegate = self
    self.userJobsTable.register(UserJobCell.self, forCellReuseIdentifier: "yourJob")
//        loadUserJobs()

        self.userJobsTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkIfUserAuthenticated()
        self.loadUserJobs()
        self.userJobsTable.reloadData();

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUserJobs(){
        self.userPostedJobs = []
        ref = Database.database().reference()
        self.ref.child("jobPosts").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            
            for(key,value) in postDict{
                
                // if the job belongs to the signed in user...
                if(self.userId! == key.split(separator: "-")[1]){
                    self.userPostedJobs.append(key);
                    
                    print("MATCHED")
                }
                
                

            }
            
            self.userJobsTable.reloadData()


        })
        

    }
    
    func checkIfUserAuthenticated(){
        if Auth.auth().currentUser == nil {
            let mainPage:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNav") as UIViewController
            self.present(mainPage, animated: true, completion: nil)
        }
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(userPostedJobs.count)
        return userPostedJobs.count
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "yourJob", for: indexPath) as! UserJobCell
        cell.textLabel?.text = String(self.userPostedJobs[indexPath.row].split(separator: "-")[0]) as String
        
        
        print(self.userPostedJobs[indexPath.row])
        cell.textLabel?.numberOfLines = 0
        return cell


    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        let detailedVC:DetailedJobPostingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailedJobPostingVC") as! DetailedJobPostingVC;
//        print("You selected a row")
//        //set variable for interested users view HERE
//
////        navigationController?.pushViewController(detailedVC, animated: true);
//
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let interestedUsersTable:InterestedUsersTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InterestedUsersVC") as! InterestedUsersTableViewController;
        
        interestedUsersTable.fullJobId = self.userPostedJobs[indexPath.row]
        
        self.navigationController?.pushViewController(interestedUsersTable, animated: true);

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
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
