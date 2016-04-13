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
    
    private static let defaultFontFamiliesListName = "com.botai.deaultFontFamiliesName"
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
    
    class func registerFontAt(url: NSURL, customInfo: FontInfoAttributes? = nil) {
        share.registerFontAt(url)
    }
    
    class func registeredFamilies() -> [String] {
       return share.families()
        
    }
    
    class func registeredFontsBy(familyName: String) -> [String] {
        return share.fontsBy(familyName)
    }
    
    class func familiesList() -> FontFamiliesList {
        return share.familiesList()
    }
    
    class func familiesListMoveFrom(index: Int, toIndex: Int) {
        share.familiesListMoveFrom(index, toIndex: toIndex)
    }
}

// search 
extension FontManager {
    
    private func families() -> [String] {
        
        let familiesFetch = NSFetchRequest(entityName: "FontFamily")
        
        do {
           let result = try record.managedObjectContext.executeFetchRequest(familiesFetch) as! [FontFamily]
            print(result.map {$0.familyName})
            return result.map {$0.familyName!}
        } catch {
            
            return []
        }
    }
    
    private func fontsBy(familyName: String) -> [String] {
        
        let predicate = NSPredicate(format: "familyName == %@", familyName)
        let fullNameFetch = NSFetchRequest(entityName: "Font")
        fullNameFetch.predicate = predicate
        
        do {
            let result = try record.managedObjectContext.executeFetchRequest(fullNameFetch) as! [Font]
            
            print(result.map { $0.postscriptName })
            return result.map { $0.postscriptName! }
        } catch {
            return []
        }
    }
}

// manage the register fontInfo
extension FontManager {
    
    enum FontManagerInsertResult {
        case ShouldAdd
        case Existed
        case Failture(ErrorType)
    }
    
    private func familiesListMoveFrom(index: Int, toIndex: Int) {
        let list = familiesList()
        guard let order = list.families?.mutableCopy() as? NSMutableOrderedSet else { return }
        order.exchangeObjectAtIndex(index, withObjectAtIndex: toIndex)
        list.families = order
        save()
    }
    
    private func shouldInsertFontBy(fullName: String) -> FontManagerInsertResult {

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
    
    private func shouldInsertFamilyBy(familyName: String) -> FontManagerInsertResult {
        
        let predicate = NSPredicate(format: "familyName == %@", familyName)
        let fullNameFetch = NSFetchRequest(entityName: "FontFamily")
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
        let familyName = info.familyName
        let result = shouldInsertFontBy(fullName)
        let familyResult = shouldInsertFamilyBy(familyName)
        
        if  case .ShouldAdd = result { addFont(info) } else { print("not add font") }
        if case .ShouldAdd = familyResult { addFamily(info) } else { print("not add family") }
    }
    
    private func addFont(info: FontInfoAttributes) {
        
        let context = record.managedObjectContext
        guard let entity = NSEntityDescription.entityForName("Font", inManagedObjectContext: context) else { return }

        let font = Font(entity: entity, insertIntoManagedObjectContext: context)
        font.congfigWith(info)
        
        print(" add font")
    }
    
    private func addFamily(info: FontInfoAttributes) {
        
        let context = record.managedObjectContext
        guard let entity = NSEntityDescription.entityForName("FontFamily", inManagedObjectContext: context) else { return }
        
        let font = FontFamily(entity: entity, insertIntoManagedObjectContext: context)
        font.configWith(info)
        
        print(" add family")
        
        let list = familiesList()
        if let families = list.families {
            let order = families.mutableCopy() as! NSMutableOrderedSet
            order.addObject(font)
            list.families = order
        } else {
            let order = NSOrderedSet(array: [font])
            list.families = order
        }
    }
    
    private func familiesList(name: String = FontManager.defaultFontFamiliesListName) -> FontFamiliesList {
        
        let predicate = NSPredicate(format: "name == %@", name)
        let fullNameFetch = NSFetchRequest(entityName: "FontFamiliesList")
        fullNameFetch.fetchLimit = 1
        fullNameFetch.predicate = predicate
        
        do {
            let list = try record.managedObjectContext.executeFetchRequest(fullNameFetch) as! [FontFamiliesList]
            
            if let alist = list.first {
                return alist
            } else {
                let context = record.managedObjectContext
                guard let entity = NSEntityDescription.entityForName("FontFamiliesList", inManagedObjectContext: context) else { fatalError() }
                
                let font = FontFamiliesList(entity: entity, insertIntoManagedObjectContext: context)
                font.name = name
                
                print(" add list")
                return font
            }

        } catch {
            fatalError()
        }
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
    
    private func registerFontAt(url: NSURL, customInfo: FontInfoAttributes? = nil) {
        
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

private extension FontFamily {
    func configWith(info: FontInfoAttributes) {
        familyName = info.familyName
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