//
//  User.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import Foundation

struct User: Codable {
    var id: UUID = UUID()
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String
    var postcode: String
    var memberSince: Date
    var subscriptionActive: Bool

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

extension User {
    static let sample = User(
        firstName: "John",
        lastName: "Smith",
        email: "john.smith@email.com",
        phoneNumber: "07700 900123",
        postcode: "SW1A 1AA",
        memberSince: Date(),
        subscriptionActive: true
    )
}
