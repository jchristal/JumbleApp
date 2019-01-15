//
//  SearchJobViewController.swift
//  Jumble
//
//  Created by Charlie Guise on 11/28/18.
//  Copyright © 2018 Team Jumble. All rights reserved.
//

import UIKit
import Firebase

class SearchJobViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var searching = false
    var searchString = ""
    var theJobs:[JobPosting] = []
    var currentFilter = ""
    var filterOptions: [String] = [String]()
//    var detailedVC = DetailedJobPostingVC();
        
    var userId:String!

    var ref: DatabaseReference!
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var filterPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkIfUserAuthenticated()
        let currentUser = Auth.auth().currentUser
        self.userId = currentUser?.uid
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "jobCell")
        
        searchBar.delegate = self
        
        filterPicker.delegate = self
        filterPicker.dataSource = self
        
        filterOptions = ["Pay", "Recency"]
        self.currentFilter = "Pay";
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.checkIfUserAuthenticated()
        fetchDataForTableView();
    }
    
    func checkIfUserAuthenticated(){
        if Auth.auth().currentUser == nil {
            let mainPage:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNav") as UIViewController
            self.present(mainPage, animated: true, completion: nil)
        }
    }
    
    func fetchDataForTableView() {
        //empty the jobs object so we don't duplicate job postings that were already in there beforehand
        self.theJobs = [];
        // initialize reference to Firebase Database
        ref = Database.database().reference()
        self.ref.child("jobPosts").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            for (key, value) in postDict {
                var theJob:JobPosting = JobPosting();
                //here, the key is the job title, so we can use this to compare to the searchString
                if(self.searching) {
                    if((key.lowercased()).contains(self.searchString.lowercased())) {
                        for (key2, value2) in value as! NSDictionary {
                            if(key2 as! String == "jobName") {
                                theJob.jobName = value2 as! String;
                            } else if(key2 as! String == "jobDescription") {
                                theJob.jobDescription = value2 as! String;
                            } else if(key2 as! String == "location") {
                                theJob.location = value2 as! String;
                            } else if(key2 as! String == "time") {
                                theJob.time = value2 as! String;
                            } else if(key2 as! String == "user") {
                                theJob.user = value2 as! String;
                            } else if(key2 as! String == "pay") {
                                theJob.pay = value2 as! Double;
                            } else if(key2 as! String == "timestamp") {
                                // citation: https://stackoverflow.com/questions/24777496/how-can-i-convert-string-date-to-nsdate
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
                                guard let date = dateFormatter.date(from: value2 as! String) else {
                                    fatalError("ERROR: Date conversion failed due to mismatched format.")
                                }
                                
                                // end citation
                                
                                theJob.timestamp = date
                            }
                            else if(key2 as! String == "firstName"){
                                theJob.firstName = value2 as! String
                            }
                            else if(key2 as! String == "lastName"){
                                theJob.lastName = value2 as! String
                            }else {
                                print("SOME VALUE NOT FOUND");
                            }
                        }
                        theJob.fullNodeName = key
                        self.theJobs.append(theJob);
                    } else {
                        continue;
                    }
                } else {
                    for (key2, value2) in value as! NSDictionary {
                        if(key2 as! String == "jobName") {
                            theJob.jobName = value2 as! String;
                        } else if(key2 as! String == "jobDescription") {
                            theJob.jobDescription = value2 as! String;
                        } else if(key2 as! String == "location") {
                            theJob.location = value2 as! String;
                        } else if(key2 as! String == "time") {
                            theJob.time = value2 as! String;
                        } else if(key2 as! String == "user") {
                            theJob.user = value2 as! String;
                        } else if(key2 as! String == "pay") {
                            theJob.pay = value2 as! Double;
                        } else if(key2 as! String == "timestamp") {
                            
                            // citation: https://stackoverflow.com/questions/24777496/how-can-i-convert-string-date-to-nsdate
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
                            guard let date = dateFormatter.date(from: value2 as! String) else {
                                fatalError("ERROR: Date conversion failed due to mismatched format.")
                            }
                            
                            // end citation
                            
                            theJob.timestamp = date
                            
                        } else if(key2 as! String == "firstName"){
                            theJob.firstName = value2 as! String
                        }
                        else if(key2 as! String == "lastName"){
                            theJob.lastName = value2 as! String
                        }else {
                            print("SOME VALUE NOT FOUND");
                        }
                    }
                    theJob.fullNodeName = key
                    self.theJobs.append(theJob);
                }
            }
            
            
            if(self.currentFilter == "Pay"){
                self.theJobs.sort(by: {$0.pay > $1.pay})
                self.tableView.reloadData()
            }
            else if(self.currentFilter == "Recency"){
                self.theJobs.sort(by: { $0.timestamp > $1.timestamp })
                self.tableView.reloadData()
            }
            
            self.tableView.reloadData();

        })
    }
    
    // Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theJobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let jobCell = UITableViewCell(style: .value1, reuseIdentifier: "jobCell")
        jobCell.textLabel!.text = theJobs[indexPath.row].jobName
        jobCell.detailTextLabel!.text = "$\(String(format: "%.2f", (round(theJobs[indexPath.row].pay*100)/100)))";
        return jobCell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailedVC:DetailedJobPostingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailedJobPostingVC") as! DetailedJobPostingVC;
        
        self.ref.child("users").child(self.userId).observeSingleEvent(of: .value) { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            
            detailedVC.hasIndicatedInterest = false

            for (key, value) in postDict {
                
                if(key == "jobsInterestedIn"){
                    for (key2, value2) in value as! NSDictionary {
                        if(self.theJobs[indexPath.row].fullNodeName == key2 as! String){
                            detailedVC.hasIndicatedInterest = true
                        }
                }
                }
                    else if(key == "firstName"){
                        detailedVC.userFirstName = value as! String
                    }
                    else if(key == "lastName"){
                        detailedVC.userLastName = value as! String

                    }
               
            }
            
            detailedVC.ownerId = self.theJobs[indexPath.row].fullNodeName;
            detailedVC.jobName = self.theJobs[indexPath.row].jobName;
          detailedVC.jobDescription = self.theJobs[indexPath.row].jobDescription;
           detailedVC.location = self.theJobs[indexPath.row].location;
         detailedVC.pay = self.theJobs[indexPath.row].pay;
           detailedVC.time = self.theJobs[indexPath.row].time;
            detailedVC.user = self.theJobs[indexPath.row].user;
          detailedVC.firstName = self.theJobs[indexPath.row].firstName;
            detailedVC.lastName = self.theJobs[indexPath.row].lastName;
            self.navigationController?.pushViewController(detailedVC, animated: true);

        }
        
//        detailedVC.ownerId = theJobs[indexPath.row].fullNodeName;
//        detailedVC.jobName = theJobs[indexPath.row].jobName;
//        detailedVC.jobDescription = theJobs[indexPath.row].jobDescription;
//        detailedVC.location = theJobs[indexPath.row].location;
//        detailedVC.pay = theJobs[indexPath.row].pay;
//        detailedVC.time = theJobs[indexPath.row].time;
//        detailedVC.user = theJobs[indexPath.row].user;
//        detailedVC.firstName = theJobs[indexPath.row].firstName;
//        detailedVC.lastName = theJobs[indexPath.row].lastName;
        
       
//        navigationController?.pushViewController(detailedVC, animated: true);

        

        
 
    }
    
    // Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filterOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filterOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentFilter = filterOptions[row]
        if (currentFilter == "Pay"){
            self.theJobs.sort(by: {$0.pay > $1.pay})
            self.tableView.reloadData()
        }
        else if (currentFilter == "Recency"){
            self.theJobs.sort(by: { $0.timestamp > $1.timestamp })
            self.tableView.reloadData()
        }
        filterPicker.isHidden = true
    }
    
    // Search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchString = searchBar.text!;
        //complete the search based on the user-specified search string
        searching = true;
        fetchDataForTableView();
        
        tableView.reloadData();
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = "";
        searching = false;
        fetchDataForTableView();
        

        tableView.reloadData();
    }
    
    // Buttons
    @IBAction func signOutClicked(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.checkIfUserAuthenticated()
    }
    
    @IBAction func filterClicked(_ sender: UIBarButtonItem) {
        filterPicker.isHidden = false
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
