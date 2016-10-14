//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Tom Sinlgeton on 14/10/2016.
//  Copyright © 2016 Tom Sinlgeton. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    @IBOutlet var fileNameLabel: UITextField!
    @IBOutlet var codeTextView: UITextView!
    @IBOutlet var gistButton: UIButton!
    var task: URLSessionDataTask?
    @IBAction func gistIt(_ sender: AnyObject) {
        guard let fileName = fileNameLabel.text, fileName.characters.count > 0 else {
            return
        }
        guard let code = codeTextView.text, code.characters.count > 0 else {
            return
        }
        let url = URL(string: "https://api.github.com/gists")!
        let json: JSON = [
            "description" : "GistIt Gist",
            "public" : false,
            "files" : [
                fileName: [
                    "content" : code
                ]
            ]
        ]
        print(json.debugDescription)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        print(request)
        guard let jsonData = try? json.rawData() else {
            return
        }
        request.httpBody = jsonData
        gistButton.isEnabled = false
        print("Disabled the button")
        gistButton.titleLabel?.text = "Gisting..."
        print("Gisting...")
        let session = URLSession.shared
        task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            print("Task Complete")
            guard error == nil else {
                DispatchQueue.main.async {
                    self.gistButton.titleLabel?.text = "Failed :/ Tap to try again"
                    self.gistButton.isEnabled = true
                }
                print("Errored")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.gistButton.titleLabel?.text = "Failed :/ Tap to try again"
                    self.gistButton.isEnabled = true
                }
                print("Errored")
                return
            }
            
            let responseJson = JSON(data: data)
            guard let gistUrlString = responseJson["html_url"].string,
            let gistUrl = URL(string: gistUrlString) else {
                DispatchQueue.main.async {
                    self.gistButton.titleLabel?.text = "Failed :/ Tap to try again"
                    self.gistButton.isEnabled = true
                }
                print("Errored")
                return
            }
            DispatchQueue.main.async {
                self.conv?.insertText(gistUrl.absoluteString, completionHandler: { (error) in
                    if let error = error {
                        print(error)
                    }
                })
                print("Success!")
                self.gistButton.titleLabel?.text = "Gist It"
                self.gistButton.isEnabled = true
                self.requestPresentationStyle(.compact)
            }
        })
        print(task)
        task?.resume()
    }
    
    var conv: MSConversation?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecogniser)
//        fileNameLabel.addGestureRecognizer(tapGestureRecogniser)
//        codeTextView.addGestureRecognizer(tapGestureRecogniser)
        setupKeyboardNotifications()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(aNotification:NSNotification) {
        let info = aNotification.userInfo
        let infoNSValue = info![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let kbSize = infoNSValue.cgRectValue.size
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
        codeTextView.contentInset = contentInsets
        codeTextView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillBeHidden(aNotification:NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        codeTextView.contentInset = contentInsets
        codeTextView.scrollIndicatorInsets = contentInsets
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
        conv = conversation
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}
