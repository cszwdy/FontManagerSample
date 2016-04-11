//
//  FontManager.swift
//  FontsManager
//
//  Created by Emiaostein on 4/11/16.
//  Copyright © 2016 Emiaostein. All rights reserved.
//

import Foundation
import UIKit

class FontManager {
    /*
     enum CTFontManagerError : CFIndex {
     case FileNotFound
     case InsufficientPermissions
     case UnrecognizedFormat
     case InvalidFontData
     case AlreadyRegistered
     case NotRegistered
     case InUse
     case SystemRequired
     }
     */
    
    enum FontManagerError {
        case FileNotFound
        case InsufficientPermissions
        case UnrecognizedFormat
        case InvalidFontData
        case NotRegistered
        case InUse
        case SystemRequired
    }
    
    enum FontManagerRegisteResult {
        case Success(FontInformation)
        case Failture(FontManagerError)
    }
    
    private static let share = FontManager()
    
//    class func registerFontAt(path: String) -> FontManagerRegisteResult {
//        return share.registerFontAt(path)
//    }
}

extension FontManager {
    
//    private func registerFontAt(path: String) -> FontManagerRegisteResult  {
//        
//        let data = NSData(contentsOfFile: path)!
//        let provider = CGDataProviderCreateWithCFData(data)
//        let cffont = CGFontCreateWithDataProvider(provider)
//        if let font = cffont where !CTFontManagerRegisterGraphicsFont(font, nil) {
//            print("Register Failture.")
//        } else {
//            print("Register Success.")
//        }
//    }
}