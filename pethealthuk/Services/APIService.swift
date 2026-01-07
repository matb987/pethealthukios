//
//  APIService.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case unauthorized
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

actor APIService {
    static let shared = APIService()

    private let baseURL = "https://api.pethealthuk.co.uk/api"
    private var authToken: String?

    private init() {}

    // MARK: - Token Management

    func setAuthToken(_ token: String?) {
        authToken = token
        if let token = token {
            UserDefaults.standard.set(token, forKey: "auth_token")
        } else {
            UserDefaults.standard.removeObject(forKey: "auth_token")
        }
    }

    func loadAuthToken() {
        authToken = UserDefaults.standard.string(forKey: "auth_token")
    }

    // MARK: - Request Building

    private func buildRequest(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil
    ) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        return request
    }

    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingError
            }
        case 401:
            throw APIError.unauthorized
        default:
            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.message)
            }
            throw APIError.serverError("Server error: \(httpResponse.statusCode)")
        }
    }

    // MARK: - Authentication

    func login(email: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(email: email, password: password)
        let request = try buildRequest(endpoint: "/auth/login", method: "POST", body: body)
        let response: AuthResponse = try await performRequest(request)
        setAuthToken(response.token)
        return response
    }

    func register(
        firstName: String,
        lastName: String,
        email: String,
        password: String,
        phoneNumber: String?,
        postcode: String
    ) async throws -> AuthResponse {
        let body = RegisterRequest(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            phoneNumber: phoneNumber,
            postcode: postcode
        )
        let request = try buildRequest(endpoint: "/auth/register", method: "POST", body: body)
        let response: AuthResponse = try await performRequest(request)
        setAuthToken(response.token)
        return response
    }

    func logout() async throws {
        let request = try buildRequest(endpoint: "/auth/logout", method: "POST")
        let _: EmptyResponse = try await performRequest(request)
        setAuthToken(nil)
    }

    // MARK: - User

    func getProfile() async throws -> UserResponse {
        let request = try buildRequest(endpoint: "/user/profile")
        return try await performRequest(request)
    }

    func updateProfile(_ profile: UpdateProfileRequest) async throws -> UserResponse {
        let request = try buildRequest(endpoint: "/user/profile", method: "PUT", body: profile)
        return try await performRequest(request)
    }

    func getDashboard() async throws -> DashboardResponse {
        let request = try buildRequest(endpoint: "/user/dashboard")
        return try await performRequest(request)
    }

    // MARK: - Pets

    func getPets() async throws -> [PetResponse] {
        let request = try buildRequest(endpoint: "/user/pets")
        return try await performRequest(request)
    }

    func createPet(_ pet: CreatePetRequest) async throws -> PetResponse {
        let request = try buildRequest(endpoint: "/pets", method: "POST", body: pet)
        return try await performRequest(request)
    }

    func updatePet(id: Int, _ pet: UpdatePetRequest) async throws -> PetResponse {
        let request = try buildRequest(endpoint: "/pets/\(id)", method: "PUT", body: pet)
        return try await performRequest(request)
    }

    func deletePet(id: Int) async throws {
        let request = try buildRequest(endpoint: "/pets/\(id)", method: "DELETE")
        let _: EmptyResponse = try await performRequest(request)
    }

    // MARK: - Clinics

    func getClinics() async throws -> [ClinicResponse] {
        let request = try buildRequest(endpoint: "/clinics")
        return try await performRequest(request)
    }

    func searchClinics(postcode: String) async throws -> [ClinicResponse] {
        let request = try buildRequest(endpoint: "/clinics/search?postcode=\(postcode)")
        return try await performRequest(request)
    }

    func getAvailableSlots(clinicId: Int, date: String) async throws -> [TimeSlotResponse] {
        let request = try buildRequest(endpoint: "/clinics/\(clinicId)/available-slots?date=\(date)")
        return try await performRequest(request)
    }

    // MARK: - Appointments

    func getAppointments() async throws -> [AppointmentResponse] {
        let request = try buildRequest(endpoint: "/user/appointments")
        return try await performRequest(request)
    }

    func createAppointment(_ appointment: CreateAppointmentRequest) async throws -> AppointmentResponse {
        let request = try buildRequest(endpoint: "/appointments/request", method: "POST", body: appointment)
        return try await performRequest(request)
    }

    func cancelAppointment(id: Int) async throws {
        let request = try buildRequest(endpoint: "/appointments/\(id)", method: "DELETE")
        let _: EmptyResponse = try await performRequest(request)
    }

    // MARK: - Symptoms

    func getSymptomCategories() async throws -> [SymptomCategoryResponse] {
        let request = try buildRequest(endpoint: "/symptoms/categories")
        return try await performRequest(request)
    }

    func startSymptomSession(petId: Int, symptoms: [String]) async throws -> SymptomSessionResponse {
        let body = StartSymptomSessionRequest(petId: petId, symptoms: symptoms)
        let request = try buildRequest(endpoint: "/symptoms/start", method: "POST", body: body)
        return try await performRequest(request)
    }

    func sendSymptomMessage(sessionId: String, message: String) async throws -> SymptomMessageResponse {
        let body = SymptomMessageRequest(sessionId: sessionId, message: message)
        let request = try buildRequest(endpoint: "/symptoms/message", method: "POST", body: body)
        return try await performRequest(request)
    }

    func getEmergencyInfo() async throws -> EmergencyInfoResponse {
        let request = try buildRequest(endpoint: "/symptoms/emergency")
        return try await performRequest(request)
    }

    // MARK: - Vaccinations

    func getVaccinations(petId: Int) async throws -> [VaccinationResponse] {
        let request = try buildRequest(endpoint: "/pets/\(petId)/vaccinations")
        return try await performRequest(request)
    }

    func createVaccination(petId: Int, _ vaccination: CreateVaccinationRequest) async throws -> VaccinationResponse {
        let request = try buildRequest(endpoint: "/pets/\(petId)/vaccinations", method: "POST", body: vaccination)
        return try await performRequest(request)
    }

    // MARK: - Medications

    func getMedications(petId: Int) async throws -> [MedicationResponse] {
        let request = try buildRequest(endpoint: "/pets/\(petId)/medications")
        return try await performRequest(request)
    }

    func getActiveMedications(petId: Int) async throws -> [MedicationResponse] {
        let request = try buildRequest(endpoint: "/pets/\(petId)/medications/active")
        return try await performRequest(request)
    }
}

// MARK: - Request/Response Models

struct LoginRequest: Encodable, Sendable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable, Sendable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let phoneNumber: String?
    let postcode: String

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case password
        case phoneNumber = "phone_number"
        case postcode
    }
}

struct AuthResponse: Decodable, Sendable {
    let token: String
    let user: UserResponse
}

struct UserResponse: Decodable, Sendable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String?
    let postcode: String?
    let memberSince: String?
    let subscriptionActive: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phoneNumber = "phone_number"
        case postcode
        case memberSince = "member_since"
        case subscriptionActive = "subscription_active"
    }
}

struct UpdateProfileRequest: Encodable, Sendable {
    let firstName: String
    let lastName: String
    let phoneNumber: String?
    let postcode: String?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case postcode
    }
}

struct DashboardResponse: Decodable, Sendable {
    let upcomingAppointments: [AppointmentResponse]
    let pets: [PetResponse]
    let notifications: [NotificationResponse]?

    enum CodingKeys: String, CodingKey {
        case upcomingAppointments = "upcoming_appointments"
        case pets
        case notifications
    }
}

struct PetResponse: Decodable, Sendable {
    let id: Int
    let name: String
    let species: String
    let breed: String
    let dateOfBirth: String?
    let weight: Double?
    let microchipNumber: String?

    enum CodingKeys: String, CodingKey {
        case id, name, species, breed
        case dateOfBirth = "date_of_birth"
        case weight
        case microchipNumber = "microchip_number"
    }
}

struct CreatePetRequest: Encodable, Sendable {
    let name: String
    let species: String
    let breed: String
    let dateOfBirth: String?
    let weight: Double?
    let microchipNumber: String?

    enum CodingKeys: String, CodingKey {
        case name, species, breed
        case dateOfBirth = "date_of_birth"
        case weight
        case microchipNumber = "microchip_number"
    }
}

struct UpdatePetRequest: Encodable, Sendable {
    let name: String
    let species: String
    let breed: String
    let dateOfBirth: String?
    let weight: Double?
    let microchipNumber: String?

    enum CodingKeys: String, CodingKey {
        case name, species, breed
        case dateOfBirth = "date_of_birth"
        case weight
        case microchipNumber = "microchip_number"
    }
}

struct ClinicResponse: Decodable, Sendable {
    let id: Int
    let name: String
    let address: String
    let postcode: String
    let phoneNumber: String
    let email: String?
    let latitude: Double
    let longitude: Double
    let isEmergency: Bool
    let is24Hours: Bool
    let services: [String]?
    let distance: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, address, postcode
        case phoneNumber = "phone_number"
        case email, latitude, longitude
        case isEmergency = "is_emergency"
        case is24Hours = "is_24_hours"
        case services, distance
    }
}

struct TimeSlotResponse: Decodable, Sendable {
    let time: String
    let available: Bool
}

struct AppointmentResponse: Decodable, Sendable {
    let id: Int
    let petId: Int
    let petName: String
    let clinicId: Int
    let clinicName: String
    let type: String
    let dateTime: String
    let duration: Int
    let status: String
    let notes: String?
    let veterinarian: String?

    enum CodingKeys: String, CodingKey {
        case id
        case petId = "pet_id"
        case petName = "pet_name"
        case clinicId = "clinic_id"
        case clinicName = "clinic_name"
        case type
        case dateTime = "date_time"
        case duration, status, notes, veterinarian
    }
}

struct CreateAppointmentRequest: Encodable, Sendable {
    let petId: Int
    let clinicId: Int
    let type: String
    let dateTime: String
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case petId = "pet_id"
        case clinicId = "clinic_id"
        case type
        case dateTime = "date_time"
        case notes
    }
}

struct SymptomCategoryResponse: Decodable, Sendable {
    let id: Int
    let name: String
    let icon: String
    let symptoms: [SymptomResponse]
}

struct SymptomResponse: Decodable, Sendable {
    let id: Int
    let name: String
    let description: String
    let severity: String
}

struct StartSymptomSessionRequest: Encodable, Sendable {
    let petId: Int
    let symptoms: [String]

    enum CodingKeys: String, CodingKey {
        case petId = "pet_id"
        case symptoms
    }
}

struct SymptomSessionResponse: Decodable, Sendable {
    let sessionId: String
    let message: String
    let recommendations: [String]?

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case message
        case recommendations
    }
}

struct SymptomMessageRequest: Encodable, Sendable {
    let sessionId: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case message
    }
}

struct SymptomMessageResponse: Decodable, Sendable {
    let message: String
    let severity: String?
    let recommendations: [String]?
    let seekVetImmediately: Bool?

    enum CodingKeys: String, CodingKey {
        case message, severity, recommendations
        case seekVetImmediately = "seek_vet_immediately"
    }
}

struct EmergencyInfoResponse: Decodable, Sendable {
    let emergencyNumber: String
    let emergencyClinics: [ClinicResponse]
    let firstAidTips: [String]

    enum CodingKeys: String, CodingKey {
        case emergencyNumber = "emergency_number"
        case emergencyClinics = "emergency_clinics"
        case firstAidTips = "first_aid_tips"
    }
}

struct VaccinationResponse: Decodable, Sendable {
    let id: Int
    let petId: Int
    let name: String
    let dateGiven: String
    let nextDueDate: String?
    let veterinarian: String?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case id
        case petId = "pet_id"
        case name
        case dateGiven = "date_given"
        case nextDueDate = "next_due_date"
        case veterinarian, notes
    }
}

struct CreateVaccinationRequest: Encodable, Sendable {
    let name: String
    let dateGiven: String
    let nextDueDate: String?
    let veterinarian: String?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case name
        case dateGiven = "date_given"
        case nextDueDate = "next_due_date"
        case veterinarian, notes
    }
}

struct MedicationResponse: Decodable, Sendable {
    let id: Int
    let petId: Int
    let name: String
    let dosage: String
    let frequency: String
    let startDate: String
    let endDate: String?
    let status: String
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case id
        case petId = "pet_id"
        case name, dosage, frequency
        case startDate = "start_date"
        case endDate = "end_date"
        case status, notes
    }
}

struct NotificationResponse: Decodable, Sendable {
    let id: Int
    let title: String
    let message: String
    let type: String
    let read: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, message, type, read
        case createdAt = "created_at"
    }
}

struct APIErrorResponse: Decodable, Sendable {
    let message: String
}

struct EmptyResponse: Decodable, Sendable {}
