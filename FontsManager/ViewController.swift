//
//  ViewController.swift
//  FontsManager
//
//  Created by Emiaostein on 4/11/16.
//  Copyright © 2016 Emiaostein. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        registerFontsByURLs()
    }
    
    func registerFont() {
        let fontFileName = "com.emiaostein.fonts.zaozigongfang.miaomiao"
        let path = NSBundle.mainBundle().pathForResource(fontFileName, ofType: "ttf")!
        let data = NSData(contentsOfFile: path)!
        let provider = CGDataProviderCreateWithCFData(data)
        let cgfont = CGFontCreateWithDataProvider(provider)
        if let font = cgfont where CTFontManagerRegisterGraphicsFont(font, nil) {
            let ctfont = CTFontCreateWithGraphicsFont(font, 1, nil, nil)
            let familyName = CTFontCopyFamilyName(ctfont)
            let fullName = CTFontCopyFullName(ctfont)
            print("family: \(familyName) \nname: \(fullName) \nRegister Success.")
        } else {
            print("Register Failture.")
        }
    }
    
    func registerFontByURL() {
        
        let fontFileName = "com.emiaostein.fonts.zaozigongfang.miaomiao"
        let path = NSBundle.mainBundle().pathForResource(fontFileName, ofType: "ttf")!
        let url = NSURL(fileURLWithPath: path)
        
        if CTFontManagerRegisterFontsForURL(url, .None, nil) {
            
            print(UIFont.familyNames())
        }
    }
    
    func registerFontsByURLs() {

        let fontsName = "Fonts"
        let path = NSBundle.mainBundle().bundleURL
        let url = path.URLByAppendingPathComponent(fontsName)
        let fontUrls = try! NSFileManager.defaultManager().contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.init(rawValue: 0))
        
        let urls = fontUrls.filter{ $0.pathExtension == "ttf" }
        
        let beforeFamilyName = UIFont.familyNames()
        if CTFontManagerRegisterFontsForURLs(urls, .Process, nil) {
            print(UIFont.familyNames().filter{ !beforeFamilyName.contains($0) })
        }
    }
    
    func fontChangedTo(name: String) {
        let descriptor = UIFontDescriptor(name: name, matrix: CGAffineTransformIdentity)
        let font = UIFont(descriptor: descriptor, size: 20)
        print(font.familyName)
        textView.font = font
    }
    
    func fontChangedBy(descriptor: UIFontDescriptor) {
        let font = UIFont(descriptor: descriptor, size: 20)
        textView.font = font
    }
}

extension ViewController {
    
    @IBAction func changeFontClick(sender: AnyObject) {
        
        let fontName = "MF MiaoMiao (Noncommercial) Regular"
        fontChangedTo(fontName)
        
//        let fontFileName = "com.emiaostein.fonts.zaozigongfang.miaomiao"
//        let path = NSBundle.mainBundle().pathForResource(fontFileName, ofType: "ttf")!
//        let data = NSData(contentsOfFile: path)!
//        if let descriptor = CTFontManagerCreateFontDescriptorFromData(data) {
//            fontChangedBy(descriptor)
//        }
    }
}
