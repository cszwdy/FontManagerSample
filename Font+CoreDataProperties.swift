//
//  Font+CoreDataProperties.swift
//  FontsManager
//
//  Created by Emiaostein on 4/13/16.
//  Copyright © 2016 Emiaostein. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Font {

    @NSManaged var familyName: String?
    @NSManaged var fullName: String?
    @NSManaged var postscriptName: String?
    @NSManaged var copyRight: String?
    @NSManaged var style: String?
    @NSManaged var version: String?

}
