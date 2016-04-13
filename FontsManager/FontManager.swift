//
//  FontManager.swift
//  FontsManager
//
//  Created by Emiaostein on 4/11/16.
//  Copyright © 2016 Emiaostein. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct FontInfo: FontInfoAttributes {
    
    let familyName: String
    let fullName: String
    let postscriptName: String
    let copyRight: String
    let style: String
    let size: String
    let version: String
}

protocol FontInfoAttributes {
    
    var familyName: String { get }
    var fullName: String { get }
    var postscriptName: String { get }
    var copyRight: String { get }
    var style: String { get }
    var version: String { get }
}

protocol FontManagerInterface {

}

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
    
    static let share = FontManager()
    private let record: DataController
    
    private init() {
        record = DataController()
        
    }
    
    @objc func notiRegisteredFontsDidChanged(noti: NSNotification) {
        
//        print(noti)
//        
//        guard noti.name == kCTFontManagerRegisteredFontsChangedNotification as String else { return }
//        guard let userInfo = noti.userInfo, let fontURLs = userInfo["CTFontManagerAvailableFontURLsAdded"] as? [NSURL] else { return }
//        
//        for url in fontURLs {
//            if let descriptor = CTFontManagerCreateFontDescriptorsFromURL(url) {
////                let r = CTFontDescriptorCopyAttributes(descriptor)
//            }
//            
//        }
        
    }
    
    class func registerFontAt(url: NSURL, customInfo: [String: FontInfoAttributes]? = nil) {
        share.registerFontAt(url)
    }
}

// manage the register fontInfo
extension FontManager {
    
    enum FontManagerInsertResult {
        case ShouldAdd
        case Existed
        case Failture(ErrorType)
    }
    
    private func shouldInsertedBy(fullName: String) -> FontManagerInsertResult {

        let predicate = NSPredicate(format: "fullName == %@", fullName)
        let fullNameFetch = NSFetchRequest(entityName: "Font")
        fullNameFetch.resultType = .CountResultType
        fullNameFetch.fetchLimit = 1
        fullNameFetch.predicate = predicate
        
        do {
            let resultCount = try record.managedObjectContext.executeFetchRequest(fullNameFetch).first! as! Int
            
            return resultCount > 0 ? .Existed : .ShouldAdd
        } catch let error {
            return .Failture(error)
        }
    }
    
    private func beganAdd(info: FontInfoAttributes) {
        
        let fullName = info.fullName
        let result = shouldInsertedBy(fullName)
        
        if  case .ShouldAdd = result { add(info) } else { print("not add") }
    }
    
    private func add(info: FontInfoAttributes) {
        
        let context = record.managedObjectContext
        guard let entity = NSEntityDescription.entityForName("Font", inManagedObjectContext: context) else { return }
        
        let font = Font(entity: entity, insertIntoManagedObjectContext: context)
        font.congfigWith(info)
        
        print(" add ")
    }
    
    private func save() {
        if record.managedObjectContext.hasChanges {
            do {
                try record.managedObjectContext.save()
            } catch {
                
            }
        }
    }
    
    
    
}


// register Font
extension FontManager {
    
    private func registerFontsAt(directoryUrl: NSURL) {
        
    }
    
    private func registerFontAt(url: NSURL, customInfo: [String: FontInfoAttributes]? = nil) {
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FontManager.notiRegisteredFontsDidChanged(_:)), name: kCTFontManagerRegisteredFontsChangedNotification as String, object: nil)
        
        // 0. registe and get the info
//        if CTFontManagerRegisterFontsForURL(url, .Process, nil) {
//        }
        
//        let urls = CTFontManagerCreateFontDescriptorsFromURL(url).map{ $0 as! CTFontDescriptor }
//        
//        print(urls)
        
        guard
            let data = NSData(contentsOfURL: url),
            let provider = CGDataProviderCreateWithCFData(data),
            let cgfont = CGFontCreateWithDataProvider(provider) where CTFontManagerRegisterGraphicsFont(cgfont, nil) else { return }
        
        let ctFont = CTFontCreateWithGraphicsFont(cgfont, 1, nil, nil)
        
        guard
            let familyName = CTFontCopyName(ctFont, kCTFontFamilyNameKey)?.toString(),
            let fullName = CTFontCopyName(ctFont,kCTFontFullNameKey)?.toString(),
            let postscriptName = CTFontCopyName(ctFont, kCTFontPostScriptNameKey)?.toString() else { return }
        
        let style = CTFontCopyName(ctFont, kCTFontStyleNameKey)?.toString() ?? ""
        let copyRight = CTFontCopyName(ctFont, kCTFontCopyrightNameKey)?.toString() ?? ""
        let version = CTFontCopyName(ctFont, kCTFontVersionNameKey)?.toString() ?? ""
        
        let fontInfo = FontInfo(
            familyName: familyName,
            fullName: fullName,
            postscriptName: postscriptName,
            copyRight: copyRight,
            style: style,
            size: "",
            version: version)
        
        beganAdd(fontInfo)
        
        save()
    }
}

private extension Font {
    func congfigWith(info: FontInfoAttributes) {
       familyName = info.familyName
       fullName = info.fullName
       postscriptName = info.postscriptName
       copyRight = info.postscriptName
       style = info.style
       version = info.version
    }
}

private extension CFString {
    
    func toString() -> String {
        return self as String
    }
}





private class DataController {
    let managedObjectContext: NSManagedObjectContext
    let manageObjectModel: NSManagedObjectModel
    
    var childObjectContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.parentContext = managedObjectContext
        return context
    }
    
    init(modelName: String = "FontManager", unitTest: Bool = false) {
        // 1.This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = NSBundle.mainBundle().URLForResource(modelName, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        // 2. The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        manageObjectModel = mom
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let docURL = urls[urls.endIndex-1]
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        
        let storeURL = docURL.URLByAppendingPathComponent("\(modelName).sqlite")
        //            let options = [NSMigratePersistentStoresAutomaticallyOption : true]
        do {
            try psc.addPersistentStoreWithType(unitTest ? NSInMemoryStoreType : NSSQLiteStoreType, configuration: nil, URL: unitTest ? nil : storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
    }
}