//
//  ViewController.swift
//  ZenTyping
//
//  Created by 村上晋太郎 on 2015/08/26.
//  Copyright (c) 2015年 村上晋太郎. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var engine = AVAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var input = engine.inputNode
        var output = engine.outputNode
        var format = input.inputFormatForBus(0)
        var error:NSError?
        
        var reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(.LargeHall2)
        reverb.wetDryMix = 50
        engine.attachNode(reverb)
        
        engine.connect(input, to: output, format: format)
        engine.startAndReturnError(&error)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

