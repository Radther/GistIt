//
//  ViewController.swift
//  GistIt for macOS
//
//  Created by Tom Sinlgeton on 15/10/2016.
//  Copyright © 2016 Tom Sinlgeton. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var fileNameField: NSTextField!
    @IBOutlet var codeField: NSTextField!
    @IBOutlet var gistUrlField: NSTextField!
    @IBOutlet var gistItButton: NSButton!
    @IBOutlet var copyButton: NSButton!
    var task: URLSessionDataTask?
    @IBAction func gistItPressed(_ sender: AnyObject) {
        let fileName = fileNameField.stringValue
        guard fileName.characters.count > 0 else {
            return
        }
        let code = codeField.stringValue
        guard code.characters.count > 0 else {
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
        gistItButton.isEnabled = false
        copyButton.isEnabled = false
        let session = URLSession.shared
        gistUrlField.stringValue = "Creating Gist"
        task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            print("Task Complete")
            guard error == nil else {
                DispatchQueue.main.async {
                    self.gistUrlField.stringValue = "Failed :/ Tap to try again"
                    self.gistItButton.isEnabled = true
                    self.copyButton.isEnabled = true
                }
                print("Errored")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.gistUrlField.stringValue = "Failed :/ Tap to try again"
                    self.gistItButton.isEnabled = true
                    self.copyButton.isEnabled = true
                }
                print("Errored")
                return
            }
            
            let responseJson = JSON(data: data)
            guard let gistUrlString = responseJson["html_url"].string,
                let gistUrl = URL(string: gistUrlString) else {
                    DispatchQueue.main.async {
                        self.gistUrlField.stringValue = "Failed :/ Tap to try again"
                        self.gistItButton.isEnabled = true
                        self.copyButton.isEnabled = true
                    }
                    print("Errored")
                    return
            }
            DispatchQueue.main.async {
                print("Success!")
                self.gistUrlField.stringValue = "\(gistUrl.absoluteString)"
                self.gistItButton.isEnabled = true
                self.copyButton.isEnabled = true
            }
        })
        print(task)
        task?.resume()
    }
    
    @IBAction func copyButtonPressed(_ sender: AnyObject) {
        NSPasteboard.general().clearContents()
        NSPasteboard.general().setString(gistUrlField.stringValue, forType: NSStringPboardType)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.window?.isReleasedWhenClosed = false
        let appDelegate = NSApp.delegate as! AppDelegate
        appDelegate.mainWindowController = self
        // Do any additional setup after loading the view.
        
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

