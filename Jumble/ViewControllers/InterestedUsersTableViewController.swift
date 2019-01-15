//
//  InterestedUsersTableViewController.swift
//  Jumble
//
//  Created by David Lie-Tjauw on 11/30/18.
//  Copyright © 2018 Team Jumble. All rights reserved.
//

import UIKit
import Firebase

class InterestedUsersTableViewController: UITableViewController {
    
    var fullJobId:String!
    var allInterestedUsers:[InterestedUser] = []
    var ref: DatabaseReference!
    @IBOutlet var interestedUsersTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Interested Users";

        print("INTERESTIN")
        print(self.fullJobId)
        self.interestedUsersTableView.dataSource = self
        self.interestedUsersTableView.delegate = self
        self.interestedUsersTableView.register(UserJobCell.self, forCellReuseIdentifier: "interestedUser")
//        self.getInterestedUsers()
        self.interestedUsersTableView.reloadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.getInterestedUsers()
        print(allInterestedUsers.count)
        self.interestedUsersTableView.reloadData();
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getInterestedUsers(){
        
        self.allInterestedUsers = []
        ref = Database.database().reference()
    self.ref.child("jobPosts").child(self.fullJobId).child("interestedUsers").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in

            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            for (key, _) in postDict {
                let raw = key.split(separator: "-")
                let firstName = ( String(raw[0]) as String)
                let lastName = ( String(raw[1]) as String)
                var interestedUser:InterestedUser = InterestedUser();
                interestedUser.userFullName = firstName + " " + lastName
                interestedUser.userId = String(raw[2]) as String
                self.allInterestedUsers.append(interestedUser)
            }

        self.interestedUsersTableView.reloadData();

        })

        

    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.allInterestedUsers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "interestedUser", for: indexPath) as! UserJobCell
        cell.textLabel?.text = self.allInterestedUsers[indexPath.row].userFullName
        
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let interestedUsersInformation:InterestedUserInformationViewController = UIStoryboard(name:"Main",bundle:nil).instantiateViewController(withIdentifier: "InterestedUserInformation") as! InterestedUserInformationViewController;
        
        interestedUsersInformation.userId = self.allInterestedUsers[indexPath.row].userId
        interestedUsersInformation.userFullName = self.allInterestedUsers[indexPath.row].userFullName

        self.navigationController?.pushViewController(interestedUsersInformation, animated: true);

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
