//
//  ChatViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

struct ChatItem {
    var text:String
    var type:BubbleDataType
}

class ChatViewController: CommonViewController, UITextFieldDelegate {

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatTextField: UITextField!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var chatList:[ChatItem] = [ChatItem(text: "How old are you?", type: .Mine),
        ChatItem(text: "i am 16", type: .Opponent),
        ChatItem(text: "agahjsg agfas f fg sdf f g gf hsdf hg g ah", type: .Opponent)]
    
    var rowHeight:[CGFloat] = []
    
    let reuseIdentifierCommand  = "chatCommandCell"
    let reuseIdentifierAnswer  = "chatAnswerCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        var string = "djasd;lkj alsdkja lkdj lajsdlk jglknvpfsjbvgnfsna[bnucenje 12 54 sati kdjaldkjslaksdjalksdjalskdj sdj aksdjl akjsd laks"
        
        chatTextField.delegate = self
        
        calculateHeight()
        
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
        chatTableView.estimatedRowHeight = 50
        chatTableView.rowHeight = UITableViewAutomaticDimension
//        chatTableView.cellHeight = chatTable
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func sendBtnAction(sender: AnyObject) {
        if  chatTextField.text != ""{
            chatList.append(ChatItem(text: chatTextField.text!, type: .Mine))
            calculateHeight()
            chatTableView.reloadData()
            chatTextField.resignFirstResponder()
            chatTextField.text = ""
        }
    }
    
    func calculateHeight(){
        rowHeight = []
        for item in chatList{
            var chatBubbleDataMine = ChatBubbleData(text: item.text, image: nil, date: NSDate(), type: item.type)
            var chatBubbleMine = ChatBubble(data: chatBubbleDataMine, startY: 5)
            rowHeight.append(CGRectGetMaxY(chatBubbleMine.frame))
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let duration:NSTimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        
        self.bottomConstraint.constant = keyboardFrame.size.height
        
        UIView.animateWithDuration(duration,
            delay: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
        if self.chatTableView.contentSize.height > self.chatTableView.frame.size.height{
            self.chatTableView.setContentOffset(CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: true)
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        var info = notification.userInfo!
        let duration:NSTimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        
        self.bottomConstraint.constant = 0
        
        UIView.animateWithDuration(duration,
            delay: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
        if self.chatTableView.contentSize.height > self.chatTableView.frame.size.height{
            self.chatTableView.setContentOffset(CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: true)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        
//        if let cell = tableView.dequeueReusableCellWithIdentifier("chatCommandCell") as? ChatCommandCell {
//            
//            var chatBubbleDataMine = ChatBubbleData(text: chatList[indexPath.row].text, image: nil, date: NSDate(), type: chatList[indexPath.row].type)
//            var chatBubbleMine = ChatBubble(data: chatBubbleDataMine, startY: 5)
//            
//            cell.backgroundColor = UIColor.clearColor()
//            
//            cell.contentView.addSubview(chatBubbleMine)
//            return cell
//        }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        
        var chatBubbleDataMine = ChatBubbleData(text: chatList[indexPath.row].text, image: nil, date: NSDate(), type: chatList[indexPath.row].type)
        var chatBubbleMine = ChatBubble(data: chatBubbleDataMine, startY: 5)
        
        cell.backgroundColor = UIColor.clearColor()
        
        cell.contentView.addSubview(chatBubbleMine)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return rowHeight[indexPath.row]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }
}

class ChatAnswerCell: UITableViewCell {
    @IBOutlet weak var lblAnswerLIne: UILabel!
    
}
class ChatCommandCell: UITableViewCell {
    
}