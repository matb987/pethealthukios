//
//  HomeView.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import SwiftUI

struct HomeView: View {
    @Environment(AppManager.self) private var appManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    welcomeHeader

                    // Emergency Banner
                    emergencyBanner

                    // Quick Actions
                    quickActionsSection

                    // Upcoming Appointments
                    if !appManager.upcomingAppointments.isEmpty {
                        upcomingAppointmentsSection
                    }

                    // My Pets Summary
                    if !appManager.pets.isEmpty {
                        myPetsSummary
                    }

                    // 24/7 Advice Line
                    adviceLineCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Pet_NHS")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let user = appManager.currentUser {
                Text("Hello, \(user.firstName)!")
                    .font(.title2)
                    .fontWeight(.bold)
            } else {
                Text("Welcome!")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            Text("How can we help you today?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emergencyBanner: some View {
        NavigationLink(destination: EmergencyView()) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Emergency?")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Tap here for immediate help")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.red, .red.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard(
                    title: "Symptom Checker",
                    icon: "stethoscope",
                    color: .blue,
                    destination: AnyView(SymptomCheckerView())
                )

                QuickActionCard(
                    title: "Find a Clinic",
                    icon: "map.fill",
                    color: .green,
                    destination: AnyView(ClinicFinderView())
                )

                QuickActionCard(
                    title: "Book Appointment",
                    icon: "calendar.badge.plus",
                    color: .purple,
                    destination: AnyView(AppointmentsView())
                )

                QuickActionCard(
                    title: "My Pets",
                    icon: "pawprint.fill",
                    color: .orange,
                    destination: AnyView(MyPetsView())
                )
            }
        }
    }

    private var upcomingAppointmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming Appointments")
                    .font(.headline)
                Spacer()
                NavigationLink("See All") {
                    AppointmentsView()
                }
                .font(.subheadline)
            }

            ForEach(appManager.upcomingAppointments.prefix(2)) { appointment in
                AppointmentCard(appointment: appointment)
            }
        }
    }

    private var myPetsSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("My Pets")
                    .font(.headline)
                Spacer()
                NavigationLink("See All") {
                    MyPetsView()
                }
                .font(.subheadline)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(appManager.pets) { pet in
                        PetSummaryCard(pet: pet)
                    }
                }
            }
        }
    }

    private var adviceLineCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "phone.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                    .frame(width: 44, height: 44)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("24/7 Advice Line")
                        .font(.headline)
                    Text("Speak to a vet nurse anytime")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Button(action: callAdviceLine) {
                Text("Call 0800 000 111")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }

    private func callAdviceLine() {
        if let url = URL(string: "tel://08000001111") {
            UIApplication.shared.open(url)
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 50, height: 50)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
    }
}

struct AppointmentCard: View {
    let appointment: Appointment

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: appointment.type.icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("\(appointment.petName) • \(appointment.clinicName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(appointment.dateTime, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(appointment.dateTime, style: .time)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

struct PetSummaryCard: View {
    let pet: Pet

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: pet.species.icon)
                .font(.title)
                .foregroundStyle(.orange)
                .frame(width: 60, height: 60)
                .background(Color.orange.opacity(0.1))
                .clipShape(Circle())

            Text(pet.name)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(pet.breed)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(width: 100)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

#Preview {
    HomeView()
        .environment(AppManager.shared)
}
