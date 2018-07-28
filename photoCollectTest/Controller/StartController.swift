//
//  ViewController.swift
//  photoCollectTest
//
//  Created by Andrew Llewellyn on 7/28/18.
//  Copyright © 2018 Andrew Llewellyn. All rights reserved.
//

import Foundation
import UIKit

class StartController: UIViewController {
    
    
    
    @IBOutlet weak var latText: UITextField!
    
    
    @IBOutlet weak var lonText: UITextField!
    
    
    @IBAction func segue(_ sender: Any) {
        
        var lat = Double(latText.text!)
        var lon = Double(lonText.text!)
        
        Location.sharedInstance().latitude = Double(latText.text!)
        Location.sharedInstance().longitude = Double(lonText.text!)
        
        let nextController = storyboard?.instantiateViewController(withIdentifier: "NavController") as! UINavigationController
        
        present(nextController, animated: true, completion: nil)
    }
    
   /* @IBAction func SearchLatLon(_ sender: Any) {
        
        var lat = Double(latText.text!)
        var lon = Double(lonText.text!)
        
        Location.sharedInstance().latitude = Double(latText.text!)
        Location.sharedInstance().longitude = Double(lonText.text!)
        
    }
    */
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    


}

