//
//  ViewController.swift
//  KidJson
//
//  Created by NguyenTheQuan on 2016/04/26.
//  Copyright © 2016年 Kid. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let person = Person()
        let dic: NSDictionary = ["id": 1, "name": "kid", "year_old": "1989"]
        var error: NSError? = nil;
        person.setUpWithDictionary(dic, error: &error)
        
        if error != nil {
            //let info = error?.userInfo;
            print("TEST " + error!.localizedDescription)
        }
        else
        {
            let name = person.name
            print("Person: name ", name)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

