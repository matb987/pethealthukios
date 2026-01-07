//
//  Appointment.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import Foundation

enum AppointmentType: String, CaseIterable, Codable, Identifiable {
    case consultation = "Consultation"
    case vaccination = "Vaccination"
    case healthCheck = "Health Check"
    case surgery = "Surgery"
    case followUp = "Follow-up"
    case emergency = "Emergency"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .consultation: return "stethoscope"
        case .vaccination: return "syringe.fill"
        case .healthCheck: return "heart.text.square.fill"
        case .surgery: return "cross.case.fill"
        case .followUp: return "arrow.triangle.2.circlepath"
        case .emergency: return "exclamationmark.triangle.fill"
        }
    }
}

enum AppointmentStatus: String, Codable {
    case scheduled = "Scheduled"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case noShow = "No Show"
}

struct Appointment: Identifiable, Codable {
    var id: UUID = UUID()
    var petId: UUID
    var petName: String
    var clinicId: UUID
    var clinicName: String
    var type: AppointmentType
    var dateTime: Date
    var duration: Int // in minutes
    var status: AppointmentStatus
    var notes: String?
    var veterinarian: String?

    var isUpcoming: Bool {
        dateTime > Date() && status == .scheduled
    }

    var isPast: Bool {
        dateTime < Date()
    }
}

extension Appointment {
    static let sampleAppointments: [Appointment] = [
        Appointment(
            petId: UUID(),
            petName: "Max",
            clinicId: UUID(),
            clinicName: "Pet_NHS Central Clinic",
            type: .vaccination,
            dateTime: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            duration: 30,
            status: .scheduled,
            veterinarian: "Dr. Sarah Wilson"
        ),
        Appointment(
            petId: UUID(),
            petName: "Luna",
            clinicId: UUID(),
            clinicName: "Pet_NHS North Clinic",
            type: .healthCheck,
            dateTime: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            duration: 45,
            status: .scheduled,
            veterinarian: "Dr. James Brown"
        )
    ]
}
