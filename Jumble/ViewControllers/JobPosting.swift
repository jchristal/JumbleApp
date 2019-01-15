//
//  JobPosting.swift
//  Jumble
//
//  Created by Emily Wiederhold on 11/15/18.
//  Copyright © 2018 Team Jumble. All rights reserved.
//

import Foundation

struct JobPosting {
    var jobDescription: String;
    var jobName: String;
    var location: String;
    var pay: Double;
    var time: String;
    var user: String;
    var timestamp:Date;
    var firstName:String;
    var lastName:String;
    var fullNodeName:String;
    
    init() {
        jobDescription = "";
        jobName = "";
        location = "";
        pay = 0.0;
        time = "";
        user = "";
        timestamp = Date();
        firstName = "";
        lastName = "";
        fullNodeName = "";
    }
}
