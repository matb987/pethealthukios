//
//  Clinic.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import Foundation
import CoreLocation

struct Clinic: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var address: String
    var postcode: String
    var phoneNumber: String
    var email: String?
    var latitude: Double
    var longitude: Double
    var isEmergency: Bool
    var is24Hours: Bool
    var services: [String]
    var openingHours: [String: String]?
    var distance: Double?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Clinic {
    static let sampleClinics: [Clinic] = [
        Clinic(
            name: "Pet_NHS Central Clinic",
            address: "123 High Street",
            postcode: "SW1A 1AA",
            phoneNumber: "020 1234 5678",
            email: "central@pethealthuk.co.uk",
            latitude: 51.5074,
            longitude: -0.1278,
            isEmergency: true,
            is24Hours: true,
            services: ["Consultations", "Vaccinations", "Surgery", "Emergency Care"],
            distance: 0.5
        ),
        Clinic(
            name: "Pet_NHS North Clinic",
            address: "45 Park Lane",
            postcode: "N1 9AB",
            phoneNumber: "020 9876 5432",
            email: "north@pethealthuk.co.uk",
            latitude: 51.5344,
            longitude: -0.1053,
            isEmergency: false,
            is24Hours: false,
            services: ["Consultations", "Vaccinations", "Health Checks"],
            distance: 2.3
        ),
        Clinic(
            name: "Pet_NHS South Clinic",
            address: "78 Bridge Road",
            postcode: "SE1 2BN",
            phoneNumber: "020 5555 1234",
            email: "south@pethealthuk.co.uk",
            latitude: 51.4975,
            longitude: -0.1357,
            isEmergency: true,
            is24Hours: false,
            services: ["Consultations", "Vaccinations", "Microchipping", "Flea Treatment"],
            distance: 1.8
        )
    ]
}
