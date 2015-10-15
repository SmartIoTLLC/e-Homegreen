//
//  ChatViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

struct ChatItem {
    var text:String
    var type:BubbleDataType
}

class ChatViewController: CommonViewController, UITextFieldDelegate {

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatTextField: UITextField!
    
    var appDel:AppDelegate!
    var devices:[Device] = []
    var scenes:[Scene] = []
    var securities:[Security] = []
    var timers:[Timer] = []
    var sequences:[Sequence] = []
    var flags:[Flag] = []
    var error:NSError? = nil
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var chatList:[ChatItem] = [ChatItem(text: "How old are you?", type: .Mine),
        ChatItem(text: "i am 16", type: .Opponent),
        ChatItem(text: "agahjsg agfas f fg sdf f g gf hsdf hg g ah", type: .Opponent)]
    
    var rowHeight:[CGFloat] = []
    
    var layout:String = "Portrait"
    
    let reuseIdentifierCommand  = "chatCommandCell"
    let reuseIdentifierAnswer  = "chatAnswerCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        var string = "djasd;lkj alsdkja lkdj lajsdlk jglknvpfsjbvgnfsna[bnucenje 12 54 sati kdjaldkjslaksdjalksdjalskdj sdj aksdjl akjsd laks"
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
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
        textToSpeech("sdaslkdhfjalsfkh alkfjal;k djs;flksja f;lkjasd ;ldkasj ;lksdj ;fldkjasf;ldkjasf dkasf;ldks j;lsdakjf ;lsadkjf ;lasdkjf ;lasvgh;lasdjghlas ghlas")
    }
    
    func textToSpeech(text:String) {
        let utterance = AVSpeechUtterance(string: text)
        let synth = AVSpeechSynthesizer()
        synth.speakUtterance(utterance)
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
    
    func fetchEntities (whatToFetch:String) {
        if whatToFetch == "Flag" {
            let fetchRequest = NSFetchRequest(entityName: "Flag")
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Flag]
                print(results.count)
                flags = results
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        if whatToFetch == "Timer" {
            let fetchRequest = NSFetchRequest(entityName: "Timer")
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Timer]
                timers = results
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        if whatToFetch == "Sequence" {
            let fetchRequest = NSFetchRequest(entityName: "Sequence")
            do {
                let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Sequence]
                sequences = results
            } catch let catchedError as NSError {
                error = catchedError
            }
            return
        }
        if whatToFetch == "Security" {
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Security")
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Security]
                securities = fetResults!
            } catch let error1 as NSError {
                error = error1
                print("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
        if whatToFetch == "Device" {
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Device")
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Device]
                devices = fetResults!
            } catch let error1 as NSError {
                error = error1
                print("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
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
        if  chatTextField.text != ""{
            chatList.append(ChatItem(text: chatTextField.text!, type: .Mine))
            calculateHeight()
            chatTableView.reloadData()
            chatTextField.resignFirstResponder()
            chatTextField.text = ""
//            showSuggestion()
            let answ = AnswersHandler()
            answ.getAnswer()
        }
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
        var chatBubbleMine = ChatBubble(data: chatBubbleDataMine, startY: 5, orientation: layout)
        
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