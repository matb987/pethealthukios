//
//  MyPetsView.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import SwiftUI

struct MyPetsView: View {
    @Environment(AppManager.self) private var appManager
    @State private var showingAddPet = false
    @State private var selectedPet: Pet?

    var body: some View {
        NavigationStack {
            Group {
                if appManager.pets.isEmpty {
                    emptyState
                } else {
                    petsList
                }
            }
            .navigationTitle("My Pets")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddPet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPet) {
                AddPetView()
            }
            .sheet(item: $selectedPet) { pet in
                PetDetailView(pet: pet)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Pets Yet", systemImage: "pawprint.fill")
        } description: {
            Text("Add your pets to track their health and book appointments.")
        } actions: {
            Button(action: { showingAddPet = true }) {
                Text("Add a Pet")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var petsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(appManager.pets) { pet in
                    PetCard(pet: pet)
                        .onTapGesture {
                            selectedPet = pet
                        }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct PetCard: View {
    let pet: Pet
    @Environment(AppManager.self) private var appManager

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: pet.species.icon)
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 70, height: 70)
                .background(
                    LinearGradient(
                        colors: [.orange, .orange.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(pet.name)
                    .font(.title3)
                    .fontWeight(.bold)

                Text(pet.breed)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Label(pet.age, systemImage: "calendar")
                    if let weight = pet.weight {
                        Label(String(format: "%.1f kg", weight), systemImage: "scalemass")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

struct AddPetView: View {
    @Environment(AppManager.self) private var appManager
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var species: PetSpecies = .dog
    @State private var breed = ""
    @State private var dateOfBirth = Date()
    @State private var weight = ""
    @State private var microchipNumber = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Pet Name", text: $name)

                    Picker("Species", selection: $species) {
                        ForEach(PetSpecies.allCases) { species in
                            Label(species.rawValue, systemImage: species.icon)
                                .tag(species)
                        }
                    }

                    TextField("Breed", text: $breed)

                    DatePicker(
                        "Date of Birth",
                        selection: $dateOfBirth,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                }

                Section("Additional Details") {
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)

                    TextField("Microchip Number", text: $microchipNumber)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePet()
                    }
                    .disabled(name.isEmpty || breed.isEmpty)
                }
            }
        }
    }

    private func savePet() {
        let pet = Pet(
            name: name,
            species: species,
            breed: breed,
            dateOfBirth: dateOfBirth,
            weight: Double(weight),
            microchipNumber: microchipNumber.isEmpty ? nil : microchipNumber
        )
        appManager.addPet(pet)
        dismiss()
    }
}

struct PetDetailView: View {
    let pet: Pet
    @Environment(AppManager.self) private var appManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Pet Header
                    petHeader

                    // Details Section
                    detailsSection

                    // Health Records Section
                    healthRecordsSection

                    // Quick Actions
                    quickActionsSection

                    // Delete Button
                    deleteButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(pet.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                }
            }
            .alert("Delete Pet", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    appManager.deletePet(pet)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to remove \(pet.name) from your pets? This action cannot be undone.")
            }
            .sheet(isPresented: $showingEditSheet) {
                EditPetView(pet: pet)
            }
        }
    }

    private var petHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: pet.species.icon)
                .font(.system(size: 50))
                .foregroundStyle(.white)
                .frame(width: 100, height: 100)
                .background(
                    LinearGradient(
                        colors: [.orange, .orange.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())

            VStack(spacing: 4) {
                Text(pet.name)
                    .font(.title)
                    .fontWeight(.bold)
                Text(pet.breed)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.headline)

            VStack(spacing: 0) {
                DetailRow(icon: "calendar", title: "Age", value: pet.age)
                Divider().padding(.leading, 44)

                if let weight = pet.weight {
                    DetailRow(icon: "scalemass", title: "Weight", value: String(format: "%.1f kg", weight))
                    Divider().padding(.leading, 44)
                }

                DetailRow(icon: "pawprint", title: "Species", value: pet.species.rawValue)
                Divider().padding(.leading, 44)

                if let microchip = pet.microchipNumber {
                    DetailRow(icon: "barcode", title: "Microchip", value: microchip)
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var healthRecordsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health Records")
                .font(.headline)

            VStack(spacing: 12) {
                HealthRecordButton(icon: "syringe.fill", title: "Vaccinations", color: .blue)
                HealthRecordButton(icon: "pills.fill", title: "Medications", color: .green)
                HealthRecordButton(icon: "heart.text.square.fill", title: "Medical History", color: .red)
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)

            HStack(spacing: 12) {
                NavigationLink(destination: SymptomCheckerView()) {
                    QuickActionButton(icon: "stethoscope", title: "Check Symptoms", color: .blue)
                }

                NavigationLink(destination: AppointmentsView()) {
                    QuickActionButton(icon: "calendar.badge.plus", title: "Book Appointment", color: .purple)
                }
            }
        }
    }

    private var deleteButton: some View {
        Button(action: { showingDeleteAlert = true }) {
            Text("Remove Pet")
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
        .padding()
    }
}

struct HealthRecordButton: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)

            Text(title)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct EditPetView: View {
    let pet: Pet
    @Environment(AppManager.self) private var appManager
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var species: PetSpecies
    @State private var breed: String
    @State private var dateOfBirth: Date
    @State private var weight: String
    @State private var microchipNumber: String

    init(pet: Pet) {
        self.pet = pet
        _name = State(initialValue: pet.name)
        _species = State(initialValue: pet.species)
        _breed = State(initialValue: pet.breed)
        _dateOfBirth = State(initialValue: pet.dateOfBirth)
        _weight = State(initialValue: pet.weight.map { String($0) } ?? "")
        _microchipNumber = State(initialValue: pet.microchipNumber ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Pet Name", text: $name)

                    Picker("Species", selection: $species) {
                        ForEach(PetSpecies.allCases) { species in
                            Label(species.rawValue, systemImage: species.icon)
                                .tag(species)
                        }
                    }

                    TextField("Breed", text: $breed)

                    DatePicker(
                        "Date of Birth",
                        selection: $dateOfBirth,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                }

                Section("Additional Details") {
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)

                    TextField("Microchip Number", text: $microchipNumber)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Edit Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePet()
                    }
                    .disabled(name.isEmpty || breed.isEmpty)
                }
            }
        }
    }

    private func savePet() {
        var updatedPet = pet
        updatedPet.name = name
        updatedPet.species = species
        updatedPet.breed = breed
        updatedPet.dateOfBirth = dateOfBirth
        updatedPet.weight = Double(weight)
        updatedPet.microchipNumber = microchipNumber.isEmpty ? nil : microchipNumber

        appManager.updatePet(updatedPet)
        dismiss()
    }
}

#Preview {
    MyPetsView()
        .environment(AppManager.shared)
}
