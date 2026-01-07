//
//  Pet.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import Foundation

enum PetSpecies: String, CaseIterable, Codable, Identifiable {
    case dog = "Dog"
    case cat = "Cat"
    case rabbit = "Rabbit"
    case guineaPig = "Guinea Pig"
    case hamster = "Hamster"
    case bird = "Bird"
    case reptile = "Reptile"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dog: return "dog.fill"
        case .cat: return "cat.fill"
        case .rabbit: return "hare.fill"
        case .guineaPig, .hamster: return "pawprint.fill"
        case .bird: return "bird.fill"
        case .reptile: return "lizard.fill"
        case .other: return "pawprint.fill"
        }
    }
}

struct Pet: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var species: PetSpecies
    var breed: String
    var dateOfBirth: Date
    var weight: Double?
    var microchipNumber: String?
    var imageData: Data?
    var notes: String?

    var age: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: dateOfBirth, to: Date())
        if let years = components.year, years > 0 {
            return "\(years) year\(years == 1 ? "" : "s")"
        } else if let months = components.month {
            return "\(months) month\(months == 1 ? "" : "s")"
        }
        return "< 1 month"
    }
}

struct VaccinationRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var petId: UUID
    var name: String
    var dateGiven: Date
    var nextDueDate: Date?
    var veterinarian: String?
    var notes: String?
}
