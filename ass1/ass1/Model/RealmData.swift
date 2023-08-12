//
//  RealmData.swift
//  ass1
//
//  Created by Inito on 12/08/23.
//

import Foundation
import RealmSwift

class RealmInfo: Object {
    @objc dynamic var product_id = ""
    @objc dynamic var checkout_url: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var button_text: String = ""
}
