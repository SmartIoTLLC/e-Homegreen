//
//  ChatViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class ChatViewController: CommonViewController {

    @IBOutlet weak var chatTableView: UITableView!
    let reuseIdentifierCommand  = "chatCommandCell"
    let reuseIdentifierAnswer  = "chatAnswerCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        var string = "djasd;lkj alsdkja lkdj lajsdlk jglknvpfsjbvgnfsna[bnucenje 12 54 sati kdjaldkjslaksdjalksdjalskdj sdj aksdjl akjsd laks"
        
        
        
        let string:NSString = "asfljsdhgfldhksflBLAdlhjasflahfljjsflblap"
        let range = string.rangeOfString("flj")
        //        println(string.rangeOfString("BLA", options: nil, range: string.startIndex, locale: nil))
        if string.rangeOfString("flj").location != NSNotFound {
            print("exists")
            print(range.location)
            print(range.location+range.length-1)
        }
//        var range = checkString.rangeOfString(searchWord.uppercaseString)
//        if checkString.rangeOfString(searchWord.uppercaseString).location != NSNotFound {
//            
//        }
        
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ChatViewController: UITableViewDelegate {
    
}

extension ChatViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}

class ChatAnswerCell: UITableViewCell {
    @IBOutlet weak var lblAnswerLIne: UILabel!
    
}
class ChatCommandCell: UITableViewCell {
    @IBOutlet weak var lblCommandLine: UILabel!
    
}