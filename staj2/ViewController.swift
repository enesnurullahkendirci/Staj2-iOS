//
//  ViewController.swift
//  staj2
//
//  Created by Enes Nurullah Kendirci on 13.02.2021.
//

import FirebaseDatabase
import UIKit
import Foundation

class ViewController: UIViewController {

    private let database = Database.database().reference()
    
    
    var keyArray = [String]()
    var dataArray: [String] = []

    @IBOutlet weak var myImageView: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.

            
        self.database.child("esp32-cam").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                print("else")
                return
            }
            for (key, _) in value{
                self.keyArray.append(key)
            }
            
            let parent = self.keyArray.last!
            var path = ""
            
            path = parent + "/photo"
            
            self.database.child("esp32-cam").child(path).observeSingleEvent(of: .value, with: { snapshot in
                guard let valueData = snapshot.value as? String else {
                    print("else")
                    return
                }
                print(valueData)
                //burdan itibaren
                
            })
        
        })
        
    }

    
    

    

}

