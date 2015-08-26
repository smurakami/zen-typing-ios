//
//  ViewController.swift
//  ZenTyping
//
//  Created by 村上晋太郎 on 2015/08/26.
//  Copyright (c) 2015年 村上晋太郎. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let remoteIO = RemoteIO()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        remoteIO.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

