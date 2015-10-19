//
//  ChatViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
//import CoreData
import AVFoundation

struct ChatItem {
    var text:String
    var type:BubbleDataType
}

class ChatViewController: CommonViewController, UITextViewDelegate, ChatDeviceDelegate {

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
//    @IBOutlet weak var chatTextField: UITextField!
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var chatTextView: UITextView!
    
//    var appDel:AppDelegate!
//    var devices:[Device] = []
//    var scenes:[Scene] = []
//    var securities:[Security] = []
//    var timers:[Timer] = []
//    var sequences:[Sequence] = []
//    var flags:[Flag] = []
//    var error:NSError? = nil
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var chatList:[ChatItem] = []
    
    var rowHeight:[CGFloat] = []
    
    var layout:String = "Portrait"
    
    let reuseIdentifierCommand  = "chatCommandCell"
    let reuseIdentifierAnswer  = "chatAnswerCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        var string = "djasd;lkj alsdkja lkdj lajsdlk jglknvpfsjbvgnfsna[bnucenje 12 54 sati kdjaldkjslaksdjalksdjalskdj sdj aksdjl akjsd laks"
        
//        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        chatTextView.delegate = self
        chatTextView.layer.borderWidth = 1
        chatTextView.layer.cornerRadius = 5
        chatTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        
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
//        textToSpeech("sdaslkdhfjalsfkh alkfjal;k djs;flksja f;lkjasd ;ldkasj ;lksdj ;fldkjasf;ldkjasf dkasf;ldks j;lsdakjf ;lsadkjf ;lasdkjf ;lasvgh;lasdjghlas ghlas")
    }
    
    func textViewDidChange(textView: UITextView) {
        
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        if newFrame.size.height + 60 < 150{
            textView.frame = newFrame
            viewHeight.constant = textView.frame.size.height + 16
            if self.chatTableView.contentSize.height > self.chatTableView.frame.size.height{
                self.chatTableView.setContentOffset(CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: false)
            }
        }
        
        
    }
    
    func textToSpeech(text:String) {
        let utterance = AVSpeechUtterance(string: text)
        let synth = AVSpeechSynthesizer()
        synth.speakUtterance(utterance)
//        synth.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
    }
    
    func searchForTermInString (text:String, searchTerm:String) {
        let string:NSString = text.lowercaseString
        let searchTerm = searchTerm.lowercaseString
        let trimmedString = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        print(string)
        print(trimmedString)
        let range = string.rangeOfString(searchTerm)
        print(string.componentsSeparatedByString(searchTerm).count-1)
        if string.rangeOfString(searchTerm).location != NSNotFound {
            print("exists")
            print(range.location)
            print(range.location+range.length-1)
        }
    }
    
       
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            layout = "Landscape"
        }else{
            layout = "Portrait"
        }
        chatTableView.reloadData()
    }
    
    @IBAction func sendBtnAction(sender: AnyObject) {
        if  chatTextView.text != ""{
            chatList.append(ChatItem(text: chatTextView.text!, type: .Mine))
            calculateHeight()
            chatTableView.reloadData()
            chatTextView.resignFirstResponder()
            
            if let _ = findCommand("") {
                showSuggestion().delegate = self
            }else{
            if chatTextView.text?.lowercaseString == "tell me a joke"{
                let joke = TellMeAJokeHandler()
                joke.getJokeCompletion({ (result) -> Void in
                    dispatch_async(dispatch_get_main_queue(),{
                        self.chatList.append(ChatItem(text: result, type: .Opponent))
                        self.calculateHeight()
                        self.chatTableView.reloadData()
                        self.textToSpeech(result)
                        if self.chatTableView.contentSize.height > self.chatTableView.frame.size.height{
                            self.chatTableView.setContentOffset(CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: true)
                        }
                    })
                })
            }else{
                let answ = AnswersHandler()
                answ.getAnswerComplition(chatTextView.text!, completion: { (result) -> Void in
                    if result != ""{
                        dispatch_async(dispatch_get_main_queue(),{
                            self.chatList.append(ChatItem(text: result, type: .Opponent))
                            self.calculateHeight()
                            self.chatTableView.reloadData()
                            self.textToSpeech(result)
                            if self.chatTableView.contentSize.height > self.chatTableView.frame.size.height{
                                self.chatTableView.setContentOffset(CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: true)
                            }
                        })
                    }else{
                        dispatch_async(dispatch_get_main_queue(),{
                            self.chatList.append(ChatItem(text: "Wrong question!!!", type: .Opponent))
                            self.calculateHeight()
                            self.chatTableView.reloadData()
                            if self.chatTableView.contentSize.height > self.chatTableView.frame.size.height{
                                self.chatTableView.setContentOffset(CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: true)
                            }
                        })
                    }
                    
                })
            }
            }
            chatTextView.text = ""
        }
    }
    
    func choosedDevice(device: String) {
        
    }
    
    func findCommand(string:String) -> String?{
        return nil
    }
    
    func calculateHeight(){
        rowHeight = []
        for item in chatList{
            let chatBubbleDataMine = ChatBubbleData(text: item.text, image: nil, date: NSDate(), type: item.type)
            let chatBubbleMine = ChatBubble(data: chatBubbleDataMine, startY: 5, orientation: layout)
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
        viewHeight.constant = 46
        
        UIView.animateWithDuration(duration,
            delay: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
        if self.chatTableView.contentSize.height > self.chatTableView.frame.size.height{
            self.chatTableView.setContentOffset(CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: false)
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
        
        let chatBubbleDataMine = ChatBubbleData(text: chatList[indexPath.row].text, image: nil, date: NSDate(), type: chatList[indexPath.row].type)
        let chatBubbleMine = ChatBubble(data: chatBubbleDataMine, startY: 5, orientation: layout)
        
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