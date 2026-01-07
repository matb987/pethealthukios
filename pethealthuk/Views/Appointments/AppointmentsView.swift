//
//  AppointmentsView.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import SwiftUI

struct AppointmentsView: View {
    @Environment(AppManager.self) private var appManager
    @State private var showingBookAppointment = false
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Appointments", selection: $selectedTab) {
                    Text("Upcoming").tag(0)
                    Text("Past").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                // Content
                if selectedTab == 0 {
                    upcomingAppointmentsView
                } else {
                    pastAppointmentsView
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Appointments")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingBookAppointment = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingBookAppointment) {
                BookAppointmentView()
            }
        }
    }

    private var upcomingAppointmentsView: some View {
        Group {
            if appManager.upcomingAppointments.isEmpty {
                ContentUnavailableView {
                    Label("No Upcoming Appointments", systemImage: "calendar")
                } description: {
                    Text("Book an appointment to see your vet.")
                } actions: {
                    Button(action: { showingBookAppointment = true }) {
                        Text("Book Appointment")
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(appManager.upcomingAppointments) { appointment in
                            AppointmentDetailCard(appointment: appointment)
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private var pastAppointmentsView: some View {
        Group {
            if appManager.pastAppointments.isEmpty {
                ContentUnavailableView {
                    Label("No Past Appointments", systemImage: "clock.arrow.circlepath")
                } description: {
                    Text("Your appointment history will appear here.")
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(appManager.pastAppointments) { appointment in
                            AppointmentDetailCard(appointment: appointment, isPast: true)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct AppointmentDetailCard: View {
    let appointment: Appointment
    var isPast: Bool = false
    @Environment(AppManager.self) private var appManager
    @State private var showingCancelAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: appointment.type.icon)
                    .font(.title2)
                    .foregroundStyle(isPast ? Color.secondary : Color.blue)
                    .frame(width: 44, height: 44)
                    .background(isPast ? Color.gray.opacity(0.1) : Color.blue.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(appointment.type.rawValue)
                        .font(.headline)
                    Text(appointment.petName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(appointment.dateTime, style: .date)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(appointment.dateTime, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            // Details
            VStack(spacing: 8) {
                DetailInfoRow(icon: "building.2.fill", label: "Clinic", value: appointment.clinicName)

                if let vet = appointment.veterinarian {
                    DetailInfoRow(icon: "person.fill", label: "Veterinarian", value: vet)
                }

                DetailInfoRow(icon: "clock.fill", label: "Duration", value: "\(appointment.duration) minutes")
            }

            // Actions (for upcoming appointments)
            if !isPast && appointment.status == .scheduled {
                Divider()

                HStack(spacing: 12) {
                    Button(action: { showingCancelAlert = true }) {
                        Text("Cancel")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    Button(action: {}) {
                        Text("Reschedule")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }

            // Status badge for past appointments
            if isPast {
                HStack {
                    Spacer()
                    Text(appointment.status.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(appointment.status == .completed ? .green : .orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(appointment.status == .completed ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        .alert("Cancel Appointment", isPresented: $showingCancelAlert) {
            Button("Keep Appointment", role: .cancel) { }
            Button("Cancel Appointment", role: .destructive) {
                appManager.cancelAppointment(appointment)
            }
        } message: {
            Text("Are you sure you want to cancel this appointment? You may need to rebook.")
        }
    }
}

struct DetailInfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct BookAppointmentView: View {
    @Environment(AppManager.self) private var appManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPet: Pet?
    @State private var selectedClinic: Clinic?
    @State private var appointmentType: AppointmentType = .consultation
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var notes = ""
    @State private var currentStep = 1

    var canProceed: Bool {
        switch currentStep {
        case 1: return selectedPet != nil
        case 2: return selectedClinic != nil
        case 3: return true
        default: return false
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Indicator
                progressIndicator

                // Content
                TabView(selection: $currentStep) {
                    selectPetStep.tag(1)
                    selectClinicStep.tag(2)
                    selectDateTimeStep.tag(3)
                    confirmationStep.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)

                // Navigation Buttons
                navigationButtons
            }
            .navigationTitle("Book Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(1...4, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10)
            }
        }
        .padding()
    }

    private var selectPetStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Select a Pet")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Choose which pet this appointment is for")
                    .foregroundStyle(.secondary)

                if appManager.pets.isEmpty {
                    ContentUnavailableView {
                        Label("No Pets", systemImage: "pawprint.fill")
                    } description: {
                        Text("Add a pet first to book an appointment.")
                    }
                } else {
                    ForEach(appManager.pets) { pet in
                        PetSelectionCard(pet: pet, isSelected: selectedPet?.id == pet.id) {
                            selectedPet = pet
                        }
                    }
                }
            }
            .padding()
        }
    }

    private var selectClinicStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Select a Clinic")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Choose your preferred Pet_NHS clinic")
                    .foregroundStyle(.secondary)

                ForEach(Clinic.sampleClinics) { clinic in
                    ClinicSelectionCard(clinic: clinic, isSelected: selectedClinic?.id == clinic.id) {
                        selectedClinic = clinic
                    }
                }
            }
            .padding()
        }
    }

    private var selectDateTimeStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Select Date & Time")
                    .font(.title2)
                    .fontWeight(.bold)

                // Appointment Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("Appointment Type")
                        .font(.headline)

                    Picker("Type", selection: $appointmentType) {
                        ForEach(AppointmentType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // Date Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date")
                        .font(.headline)

                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // Time Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Time")
                        .font(.headline)

                    DatePicker(
                        "Select Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes (Optional)")
                        .font(.headline)

                    TextField("Any additional information...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()
        }
    }

    private var confirmationStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Confirm Booking")
                    .font(.title2)
                    .fontWeight(.bold)

                // Summary Card
                VStack(alignment: .leading, spacing: 16) {
                    if let pet = selectedPet {
                        SummaryRow(icon: "pawprint.fill", label: "Pet", value: pet.name)
                    }

                    if let clinic = selectedClinic {
                        SummaryRow(icon: "building.2.fill", label: "Clinic", value: clinic.name)
                    }

                    SummaryRow(icon: appointmentType.icon, label: "Type", value: appointmentType.rawValue)

                    SummaryRow(icon: "calendar", label: "Date", value: selectedDate.formatted(date: .long, time: .omitted))

                    SummaryRow(icon: "clock.fill", label: "Time", value: selectedTime.formatted(date: .omitted, time: .shortened))

                    if !notes.isEmpty {
                        SummaryRow(icon: "note.text", label: "Notes", value: notes)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Confirmation Notice
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                    Text("You will receive a confirmation SMS and email after booking.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding()
        }
    }

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if currentStep > 1 {
                Button(action: { currentStep -= 1 }) {
                    Text("Back")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            Button(action: {
                if currentStep < 4 {
                    currentStep += 1
                } else {
                    bookAppointment()
                }
            }) {
                Text(currentStep == 4 ? "Confirm Booking" : "Continue")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canProceed ? Color.accentColor : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(!canProceed)
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private func bookAppointment() {
        guard let pet = selectedPet, let clinic = selectedClinic else { return }

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)

        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute

        let appointmentDateTime = calendar.date(from: combinedComponents) ?? Date()

        let appointment = Appointment(
            petId: pet.id,
            petName: pet.name,
            clinicId: clinic.id,
            clinicName: clinic.name,
            type: appointmentType,
            dateTime: appointmentDateTime,
            duration: 30,
            status: .scheduled,
            notes: notes.isEmpty ? nil : notes
        )

        appManager.addAppointment(appointment)
        dismiss()
    }
}

struct PetSelectionCard: View {
    let pet: Pet
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: pet.species.icon)
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .frame(width: 50, height: 50)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(pet.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(pet.breed)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title2)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct ClinicSelectionCard: View {
    let clinic: Clinic
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "building.2.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 50, height: 50)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(clinic.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(clinic.address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title2)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    AppointmentsView()
        .environment(AppManager.shared)
}
