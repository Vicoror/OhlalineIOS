//
//  Login+CoreDataProperties.swift
//  Oh-laline
//
//  Created by Victoria Ortega on 05/10/25.
//
//

import Foundation
import CoreData


extension Login {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Login> {
        return NSFetchRequest<Login>(entityName: "Login")
    }

    @NSManaged public var id_user: UUID?
    @NSManaged public var email: String?
    @NSManaged public var password: String?
    @NSManaged public var dateLogin: Date?
    @NSManaged public var motivationQuiz: Int16
    @NSManaged public var userPro: Bool

}

extension Login : Identifiable {

}
