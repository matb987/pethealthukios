//
//  SymptomCheckerView.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import SwiftUI

struct SymptomCheckerView: View {
    @Environment(AppManager.self) private var appManager
    @State private var selectedSpecies: PetSpecies?
    @State private var searchText = ""

    var filteredCategories: [SymptomCategory] {
        guard let species = selectedSpecies else {
            return SymptomCategory.categories
        }

        return SymptomCategory.categories.compactMap { category in
            let filteredSymptoms = category.symptoms.filter { symptom in
                symptom.applicableSpecies.contains(species)
            }
            if filteredSymptoms.isEmpty {
                return nil
            }
            return SymptomCategory(
                id: category.id,
                name: category.name,
                icon: category.icon,
                symptoms: filteredSymptoms
            )
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Info Banner
                    infoBanner

                    // Species Filter
                    speciesFilter

                    // Symptom Categories
                    symptomCategories

                    // Emergency Notice
                    emergencyNotice
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Symptom Checker")
            .searchable(text: $searchText, prompt: "Search symptoms...")
        }
    }

    private var infoBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text("Evidence-Based Guidance")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("Get advice on common pet health issues")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var speciesFilter: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Pet Type")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    SpeciesChip(
                        species: nil,
                        label: "All",
                        icon: "pawprint.fill",
                        isSelected: selectedSpecies == nil
                    ) {
                        selectedSpecies = nil
                    }

                    ForEach(PetSpecies.allCases) { species in
                        SpeciesChip(
                            species: species,
                            label: species.rawValue,
                            icon: species.icon,
                            isSelected: selectedSpecies == species
                        ) {
                            selectedSpecies = species
                        }
                    }
                }
            }
        }
    }

    private var symptomCategories: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Symptom Categories")
                .font(.headline)

            ForEach(filteredCategories) { category in
                NavigationLink(destination: SymptomCategoryView(category: category, selectedSpecies: selectedSpecies)) {
                    SymptomCategoryCard(category: category)
                }
            }
        }
    }

    private var emergencyNotice: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                Text("If your pet is in distress, seek immediate help")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            NavigationLink(destination: EmergencyView()) {
                Text("Go to Emergency")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SpeciesChip: View {
    let species: PetSpecies?
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(label)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.accentColor : Color(.systemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
        }
    }
}

struct SymptomCategoryCard: View {
    let category: SymptomCategory

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 50, height: 50)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("\(category.symptoms.count) symptom\(category.symptoms.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

struct SymptomCategoryView: View {
    let category: SymptomCategory
    let selectedSpecies: PetSpecies?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(category.symptoms) { symptom in
                    NavigationLink(destination: SymptomDetailView(symptom: symptom)) {
                        SymptomRow(symptom: symptom)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(category.name)
    }
}

struct SymptomRow: View {
    let symptom: Symptom

    var severityColor: Color {
        switch symptom.severity {
        case .mild: return .green
        case .moderate: return .yellow
        case .severe: return .orange
        case .emergency: return .red
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(severityColor)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                Text(symptom.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(symptom.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SymptomDetailView: View {
    let symptom: Symptom

    var severityColor: Color {
        switch symptom.severity {
        case .mild: return .green
        case .moderate: return .yellow
        case .severe: return .orange
        case .emergency: return .red
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(symptom.severity.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(severityColor)
                            .clipShape(Capsule())

                        Spacer()
                    }

                    Text(symptom.name)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(symptom.description)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Possible Causes
                sectionCard(
                    title: "Possible Causes",
                    icon: "questionmark.circle.fill",
                    color: .blue
                ) {
                    ForEach(symptom.possibleCauses, id: \.self) { cause in
                        HStack(spacing: 8) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundStyle(.secondary)
                            Text(cause)
                        }
                    }
                }

                // Home Care Advice
                sectionCard(
                    title: "Home Care Advice",
                    icon: "house.fill",
                    color: .green
                ) {
                    Text(symptom.homeAdvice)
                        .foregroundStyle(.secondary)
                }

                // When to See a Vet
                sectionCard(
                    title: "Seek Veterinary Care If",
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                ) {
                    ForEach(symptom.seekVetIf, id: \.self) { condition in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.red)
                                .font(.caption)
                            Text(condition)
                        }
                    }
                }

                // Call to Action
                VStack(spacing: 12) {
                    NavigationLink(destination: ClinicFinderView()) {
                        Text("Find a Clinic")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Button(action: callAdviceLine) {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text("Call 24/7 Advice Line")
                        }
                        .font(.headline)
                        .foregroundStyle(.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Symptom Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sectionCard<Content: View>(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.headline)
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func callAdviceLine() {
        if let url = URL(string: "tel://08000001111") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SymptomCheckerView()
        .environment(AppManager.shared)
}
