//
//  EmergencyView.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import SwiftUI
import MapKit

struct EmergencyView: View {
    @State private var emergencyClinics: [Clinic] = Clinic.sampleClinics.filter { $0.isEmergency }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Emergency Banner
                    emergencyBanner

                    // Call Now Section
                    callNowSection

                    // Emergency Clinics
                    emergencyClinicsSection

                    // First Aid Tips
                    firstAidSection

                    // Important Notice
                    importantNotice
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Emergency")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emergencyBanner: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.white)

            Text("Pet Emergency?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text("Stay calm. Help is available 24/7.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            LinearGradient(
                colors: [.red, .red.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var callNowSection: some View {
        VStack(spacing: 12) {
            Button(action: callEmergencyLine) {
                HStack(spacing: 12) {
                    Image(systemName: "phone.fill")
                        .font(.title2)

                    VStack(alignment: .leading) {
                        Text("24/7 Emergency Line")
                            .font(.headline)
                        Text("0800 000 111")
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(.white)
                .padding()
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Text("Speak to a vet nurse immediately")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var emergencyClinicsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "cross.case.fill")
                    .foregroundStyle(.red)
                Text("Nearest Emergency Clinics")
                    .font(.headline)
            }

            ForEach(emergencyClinics) { clinic in
                EmergencyClinicCard(clinic: clinic)
            }
        }
    }

    private var firstAidSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .foregroundStyle(.blue)
                Text("While You Wait")
                    .font(.headline)
            }

            VStack(spacing: 0) {
                FirstAidTip(
                    number: 1,
                    title: "Stay Calm",
                    description: "Your pet can sense your stress. Speak softly and move slowly."
                )
                Divider().padding(.leading, 44)

                FirstAidTip(
                    number: 2,
                    title: "Keep Safe",
                    description: "Injured pets may bite. Approach carefully and consider a muzzle if needed."
                )
                Divider().padding(.leading, 44)

                FirstAidTip(
                    number: 3,
                    title: "Don't Give Medication",
                    description: "Never give human medications without veterinary advice."
                )
                Divider().padding(.leading, 44)

                FirstAidTip(
                    number: 4,
                    title: "Keep Warm",
                    description: "Cover your pet with a blanket to prevent shock."
                )
                Divider().padding(.leading, 44)

                FirstAidTip(
                    number: 5,
                    title: "Transport Safely",
                    description: "Use a carrier or support the body when moving to prevent further injury."
                )
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var importantNotice: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.orange)
                Text("Important")
                    .font(.headline)
            }

            Text("If your pet is in immediate danger or you suspect poisoning, please call the emergency line immediately. Time is critical in emergencies.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func callEmergencyLine() {
        if let url = URL(string: "tel://08000001111") {
            UIApplication.shared.open(url)
        }
    }
}

struct EmergencyClinicCard: View {
    let clinic: Clinic

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(clinic.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        if clinic.is24Hours {
                            Text("24H")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .clipShape(Capsule())
                        }
                    }

                    Text("\(clinic.address), \(clinic.postcode)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let distance = clinic.distance {
                    Text(String(format: "%.1f mi", distance))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            }

            HStack(spacing: 12) {
                Button(action: { callClinic() }) {
                    Label("Call", systemImage: "phone.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .clipShape(Capsule())
                }

                Button(action: { getDirections() }) {
                    Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                }

                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }

    private func callClinic() {
        let phone = clinic.phoneNumber.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(phone)") {
            UIApplication.shared.open(url)
        }
    }

    private func getDirections() {
        let destination = MKMapItem(location: CLLocation(latitude: clinic.latitude, longitude: clinic.longitude), address: nil)
        destination.name = clinic.name
        destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

struct FirstAidTip: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Color.blue)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    EmergencyView()
        .environment(AppManager.shared)
}
