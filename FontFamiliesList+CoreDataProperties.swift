//
//  FontFamiliesList+CoreDataProperties.swift
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

extension FontFamiliesList {

    @NSManaged var name: String?
    @NSManaged var families: NSOrderedSet?

}
