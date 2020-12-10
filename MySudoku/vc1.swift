//
//  vc1.swift
//  MySudoku
//
//  Created by MSalah on 11/29/20.
//  Copyright © 2020 MSalah. All rights reserved.
//

import UIKit

class vc1:UIViewController{
    
    var level:String = "Easy"
    
    @IBOutlet weak var c: UIButton!
    
    @IBAction func levell(_ sender: UISegmentedControl) {
        level = sender.titleForSegment(at: sender.selectedSegmentIndex)!
    }
    override func viewWillAppear(_ animated: Bool) {
//        UserDefaults.standard.removeObject(forKey: "d")
        if UserDefaults.standard.object(forKey: "d") != nil{
            c.isHidden = false
        }else{c.isHidden = true}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "r"{
            UserDefaults.standard.removeObject(forKey: "d")
            print("1")
            return
        }
        let d = segue.destination as! vc2
        if segue.identifier == "segue"{
            d.udf = true
        }else{
            d.level = level
        }
    }
       
    
}
