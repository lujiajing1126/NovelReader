//
//  ViewController.swift
//  reader
//
//  Created by 陆家靖 on 16/8/21.
//  Copyright © 2016年 陆家靖. All rights reserved.
//

import UIKit
import Moya
import Foundation
import Kanna
import DTCoreText
import Regex
import SnapKit
import MBProgressHUD

class ViewController: UIViewController,DTAttributedTextContentViewDelegate {
    let currentPageKey = "current_page"
    
    var textview: DTAttributedTextView!
    let storage = NSUserDefaults.standardUserDefaults()
    
    var currentPage: Int? {
        willSet {
            storage.setInteger(newValue!, forKey: currentPageKey)
        }
        didSet {
            let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            loadingNotification.label.text = "Loading"
            self.hud = loadingNotification
            self.loadPage()
        }
    }
    var nextPage: Int?
    var previousPage: Int?
    var hud: MBProgressHUD?
    
    let css = DTCSSStylesheet(styleBlock: "#container { padding: 20px 15px 20px 15px; } .title { font-weight: bold; } #content { line-height: 15px; }")
    
    static let endpointClosure = { (target: BookService) -> Endpoint<BookService> in
        let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
        let endpoint: Endpoint<BookService> = Endpoint<BookService>(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
        return endpoint.endpointByAddingHTTPHeaderFields(["Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8","Accept-Language":"zh-CN,zh;q=0.8,en;q=0.6,ja;q=0.4,zh-TW;q=0.2","User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2824.0 Safari/537.36"])
    }
    
    let provider = MoyaProvider<BookService>(endpointClosure: endpointClosure)
    
    override func loadView() {
        super.loadView()
        
        let frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        self.textview = DTAttributedTextView(frame: frame)
        self.textview.shouldDrawLinks = false
        self.textview.shouldDrawImages = false
        self.textview.textDelegate = self
        self.view.addSubview(self.textview)
        
        self.textview.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
    
    private func loadPage() {
        provider.request(.ShowPage(bookid: 74, page: self.currentPage!)) { (result) in
            switch result {
            case let .Success(htmlResponse):
                let GBKenc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
                guard let html = String(data: htmlResponse.data, encoding: GBKenc) else {
                    print("fail")
                    break
                }
                if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
                    let title = doc.css(".bookname > h1").first?.text
                    for node in doc.css(".bottem2 > a") {
                        if node.text == "上一章" {
                            let pageStr = "(\\d+)\\.html".r?.findFirst(in: node["href"]!)?.group(at: 1)
                            let page = Int(pageStr!)
                            self.previousPage = page
                        } else if node.text == "下一章" {
                            let pageStr = "(\\d+)\\.html".r?.findFirst(in: node["href"]!)?.group(at: 1)
                            let page = Int(pageStr!)
                            self.nextPage = page
                        }
                    }
                    let content = doc.css("#content").first?.innerHTML
                    let wrappedContent = "<div id=\"container\"><h3 class=\"title\">\(title!)</h3><div id=\"content\">\(content!)</div></div>".dataUsingEncoding(NSUTF8StringEncoding)
                    var options = Dictionary<NSObject,AnyObject>()
                    options = [NSTextSizeMultiplierDocumentOption: NSNumber(float: 1.5),DTDefaultFontFamily: "HYXinRenWenSongW",DTDefaultStyleSheet: self.css]
                    let attrStr = NSAttributedString(HTMLData: wrappedContent!,options: options,documentAttributes:nil)
                    self.textview.attributedString = attrStr
                    self.textview.setContentOffset(CGPointMake(0, 0), animated: true)
                }
            case let .Failure(error):
                print("\(error)")
                // No nothing
            }
            self.hud?.hideAnimated(true)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let page = storage.integerForKey(currentPageKey)
        if page != 0 {
            self.currentPage = page
        } else {
            self.currentPage = 1799125
        }
        // Do any additional setup after loading the view, typically from a nib.
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleSwipes(_:)))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func handleSwipes(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Right:
            self.currentPage = previousPage
        case UISwipeGestureRecognizerDirection.Left:
            self.currentPage = nextPage
        default:
            print("do nothing")
        }
    }


}

