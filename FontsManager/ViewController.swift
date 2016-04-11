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
        
        let fontFileName = "com.emiaostein.fonts.zaozigongfang.miaomiao"
        let path = NSBundle.mainBundle().pathForResource(fontFileName, ofType: "ttf")!
        let data = NSData(contentsOfFile: path)!
        let provider = CGDataProviderCreateWithCFData(data)
        let cffont = CGFontCreateWithDataProvider(provider)
        if let font = cffont where !CTFontManagerRegisterGraphicsFont(font, nil) {
            print("Register Failture.")
        } else {
            print("Register Success.")
        }
    }
    
    func fontChangedTo(name: String) {
        let descriptor = UIFontDescriptor(name: name, matrix: CGAffineTransformIdentity)
        let font = UIFont(descriptor: descriptor, size: 20)
        
        textView.font = font
    }
}

extension ViewController {
    
    @IBAction func changeFontClick(sender: AnyObject) {
        
        let fontName = "MF MiaoMiao (Noncommercial) Regular"
        fontChangedTo(fontName)
    }
}
