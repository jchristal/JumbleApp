//
//  MainPageViewController.swift
//  Jumble
//
//  Created by David Lie-Tjauw on 11/2/18.
//  Copyright © 2018 Team Jumble. All rights reserved.
//

import UIKit
import FirebaseAuth

class MainPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if Auth.auth().currentUser != nil {
            print("-----------------User is logged in---------------------")
        } else {
            print("-----------------User is NOT logged in---------------------")

        }
        
        self.navigationItem.setHidesBackButton(true, animated:true);

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
