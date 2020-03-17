//
//  Pin+Extension.swift
//  VirtualTourist
//
//  Created by Kyle Wilson on 2020-03-16.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import Foundation
import CoreData

extension Pin {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
