//
//  ViewController.swift
//  nightlive
//
//  Created by Hannes Schaletzky on 25/01/2017.
//  Copyright © 2017 Hannes Schaletzky. All rights reserved.
//

import UIKit
import Parse

//Facebook
import Bolts
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Ich rasier dich")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func onPress() {
        
        print("I got pressed")
        
        let query = PFQuery(className: "Locations_Bars")
        query.findObjectsInBackground { (results, error) in
            if error != nil {
                //Error
                print("Error CallBack")
            }
            else {
                //Success
                print("Success CallBack")
                print("retrieved: \(results!.count) bars")
            }
        }
        
    }
    
    @IBAction func onPressFacebook() {
        
        print("Facebook Button Pressed")
        
        
        let acccessTokenString = getAccessTokenString()
        let fieldsToRetrieve = "id,name,description,start_time,end_time,interested_count,attending_count"
        let params = ["fields":fieldsToRetrieve , "access_token": acccessTokenString]//, "since":"\(timesStamp.0)", "until":"\(timesStamp.1)"]
        
        let request = FBSDKGraphRequest(graphPath: "/yumclub/events" , parameters: params, httpMethod: "GET")
        
        request?.start(completionHandler: { (connection, objects, error) in
            print("Callback Handling")
            if error != nil || objects == nil {
                //ERROR
                print("Error")
                print(error as! NSError)
            }
            else {
                //SUCCESS
                print(objects)
            }
        })
        
        
    }
    
    //MARK: - Additional Helper Functions
    private func getAccessTokenString() -> String {
        let token = "\(facebookAppID)|\(facebookAppSecret)"
        return token
    }

}

