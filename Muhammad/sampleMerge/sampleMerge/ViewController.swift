//
//  ViewController.swift
//  sampleMerge
//
//  Created by Muhammad Daniyal on 4/3/20.
//  Copyright © 2020 MuhammadDaniyal. All rights reserved.
//

import UIKit
//no need to import "parser.h" here because Bridging-Header.h automatically does that for us.
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let instanceOfParser: parser = parser()
        instanceOfParser.msgReceiver()
        
       // parser *object1 = [[parser alloc]init];
        
        //object1.msgReceiver();
    }


}

