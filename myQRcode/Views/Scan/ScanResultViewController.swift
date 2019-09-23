//
//  ScanResultViewController.swift
//  myQRcode
//
//  Created by Marc Hein on 28.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit

class ScanResultViewController: UIViewController {

    var codeResult: String?
    
    @IBOutlet weak var resultTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(codeResult!)
        resultTextView.text = codeResult
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
