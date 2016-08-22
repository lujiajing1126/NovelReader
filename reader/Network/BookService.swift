//
//  BookService.swift
//  reader
//
//  Created by 陆家靖 on 16/8/21.
//  Copyright © 2016年 陆家靖. All rights reserved.
//

import Foundation
import Moya

enum BookService {
    case ShowPage(bookid: Int, page: Int)
}

extension BookService: TargetType {
    var baseURL: NSURL { return NSURL(string: "http://www.biquku.com/0")! }
    
    var path: String {
        switch self {
        case .ShowPage(let book, let page):
            return "/\(book)/\(page).html"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .ShowPage:
            return .GET
        }
    }
    
    var parameters: [String: AnyObject]? {
        switch self {
        case .ShowPage:
            return nil
        }
    }
        
    var sampleData: NSData {
        switch self {
        case .ShowPage:
            return "<html></html>".UTF8EncodedData
        }
    }
    var multipartBody: [MultipartFormData]? {
        // Optional
        return nil
    }
}

// MARK: - Helpers
private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
    var UTF8EncodedData: NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding)!
    }
}