//
//  AppManager.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import Foundation
import SwiftUI

@Observable
class AppManager {
    static let shared = AppManager()

    var isLoggedIn: Bool = false
    var hasCompletedOnboarding: Bool = false
    var currentUser: User?
    var pets: [Pet] = []
    var appointments: [Appointment] = []

    private let userDefaultsKey = "pethealthuk_data"

    init() {
        loadData()
    }

    // MARK: - Pet Management

    func addPet(_ pet: Pet) {
        pets.append(pet)
        saveData()
    }

    func updatePet(_ pet: Pet) {
        if let index = pets.firstIndex(where: { $0.id == pet.id }) {
            pets[index] = pet
            saveData()
        }
    }

    func deletePet(_ pet: Pet) {
        pets.removeAll { $0.id == pet.id }
        saveData()
    }

    // MARK: - Appointment Management

    func addAppointment(_ appointment: Appointment) {
        appointments.append(appointment)
        saveData()
    }

    func updateAppointment(_ appointment: Appointment) {
        if let index = appointments.firstIndex(where: { $0.id == appointment.id }) {
            appointments[index] = appointment
            saveData()
        }
    }

    func cancelAppointment(_ appointment: Appointment) {
        if let index = appointments.firstIndex(where: { $0.id == appointment.id }) {
            appointments[index].status = .cancelled
            saveData()
        }
    }

    var upcomingAppointments: [Appointment] {
        appointments
            .filter { $0.isUpcoming }
            .sorted { $0.dateTime < $1.dateTime }
    }

    var pastAppointments: [Appointment] {
        appointments
            .filter { $0.isPast }
            .sorted { $0.dateTime > $1.dateTime }
    }

    // MARK: - User Management

    func login(user: User) {
        currentUser = user
        isLoggedIn = true
        saveData()
    }

    func logout() {
        currentUser = nil
        isLoggedIn = false
        pets = []
        appointments = []
        hasCompletedOnboarding = false
        saveData()
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        saveData()
    }

    // MARK: - Persistence

    private func saveData() {
        let data = AppData(
            isLoggedIn: isLoggedIn,
            hasCompletedOnboarding: hasCompletedOnboarding,
            currentUser: currentUser,
            pets: pets,
            appointments: appointments
        )

        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode(AppData.self, from: data) else {
            return
        }

        isLoggedIn = decoded.isLoggedIn
        hasCompletedOnboarding = decoded.hasCompletedOnboarding
        currentUser = decoded.currentUser
        pets = decoded.pets
        appointments = decoded.appointments
    }

    // MARK: - Demo Data

    func loadDemoData() {
        currentUser = User.sample
        isLoggedIn = true
        hasCompletedOnboarding = true

        pets = [
            Pet(
                name: "Max",
                species: .dog,
                breed: "Golden Retriever",
                dateOfBirth: Calendar.current.date(byAdding: .year, value: -3, to: Date())!,
                weight: 32.5,
                microchipNumber: "123456789012345"
            ),
            Pet(
                name: "Luna",
                species: .cat,
                breed: "British Shorthair",
                dateOfBirth: Calendar.current.date(byAdding: .year, value: -2, to: Date())!,
                weight: 4.2,
                microchipNumber: "987654321098765"
            )
        ]

        appointments = [
            Appointment(
                petId: pets[0].id,
                petName: pets[0].name,
                clinicId: UUID(),
                clinicName: "Pet_NHS Central Clinic",
                type: .vaccination,
                dateTime: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                duration: 30,
                status: .scheduled,
                veterinarian: "Dr. Sarah Wilson"
            ),
            Appointment(
                petId: pets[1].id,
                petName: pets[1].name,
                clinicId: UUID(),
                clinicName: "Pet_NHS North Clinic",
                type: .healthCheck,
                dateTime: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
                duration: 45,
                status: .scheduled,
                veterinarian: "Dr. James Brown"
            )
        ]

        saveData()
    }
}

struct AppData: Codable {
    var isLoggedIn: Bool
    var hasCompletedOnboarding: Bool
    var currentUser: User?
    var pets: [Pet]
    var appointments: [Appointment]
}
