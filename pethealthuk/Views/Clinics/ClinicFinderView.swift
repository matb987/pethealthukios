//
//  ClinicFinderView.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import SwiftUI
import MapKit

struct ClinicFinderView: View {
    @State private var searchText = ""
    @State private var selectedClinic: Clinic?
    @State private var showEmergencyOnly = false
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var viewMode: ViewMode = .list

    enum ViewMode {
        case list
        case map
    }

    var filteredClinics: [Clinic] {
        var clinics = Clinic.sampleClinics

        if showEmergencyOnly {
            clinics = clinics.filter { $0.isEmergency }
        }

        if !searchText.isEmpty {
            clinics = clinics.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.postcode.localizedCaseInsensitiveContains(searchText) ||
                $0.address.localizedCaseInsensitiveContains(searchText)
            }
        }

        return clinics.sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Bar
                filterBar

                // View Toggle
                viewToggle

                // Content
                if viewMode == .list {
                    clinicListView
                } else {
                    clinicMapView
                }
            }
            .navigationTitle("Find a Clinic")
            .searchable(text: $searchText, prompt: "Search by name or postcode")
            .sheet(item: $selectedClinic) { clinic in
                ClinicDetailSheet(clinic: clinic)
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "Emergency",
                    icon: "cross.case.fill",
                    isSelected: showEmergencyOnly
                ) {
                    showEmergencyOnly.toggle()
                }

                FilterChip(
                    title: "24 Hours",
                    icon: "clock.fill",
                    isSelected: false
                ) {
                    // Filter action
                }

                FilterChip(
                    title: "Near Me",
                    icon: "location.fill",
                    isSelected: false
                ) {
                    // Location filter action
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }

    private var viewToggle: some View {
        Picker("View Mode", selection: $viewMode) {
            Label("List", systemImage: "list.bullet")
                .tag(ViewMode.list)
            Label("Map", systemImage: "map")
                .tag(ViewMode.map)
        }
        .pickerStyle(.segmented)
        .padding()
        .background(Color(.systemBackground))
    }

    private var clinicListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredClinics) { clinic in
                    ClinicCard(clinic: clinic)
                        .onTapGesture {
                            selectedClinic = clinic
                        }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    private var clinicMapView: some View {
        Map(coordinateRegion: $mapRegion, annotationItems: filteredClinics) { clinic in
            MapAnnotation(coordinate: clinic.coordinate) {
                Button(action: { selectedClinic = clinic }) {
                    VStack(spacing: 4) {
                        Image(systemName: clinic.isEmergency ? "cross.case.fill" : "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(clinic.isEmergency ? .red : .blue)
                            .background(Color.white)
                            .clipShape(Circle())

                        Text(clinic.name)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color(.systemBackground))
                            .clipShape(Capsule())
                            .shadow(radius: 1)
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}

struct ClinicCard: View {
    let clinic: Clinic

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(clinic.name)
                            .font(.headline)

                        if clinic.isEmergency {
                            Text("EMERGENCY")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .clipShape(Capsule())
                        }

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

                    Text(clinic.address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(clinic.postcode)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let distance = clinic.distance {
                    VStack(alignment: .trailing) {
                        Text(String(format: "%.1f mi", distance))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                }
            }

            Divider()

            HStack(spacing: 16) {
                Button(action: { callClinic(clinic) }) {
                    Label("Call", systemImage: "phone.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Spacer()

                Button(action: { getDirections(clinic) }) {
                    Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            .foregroundStyle(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }

    private func callClinic(_ clinic: Clinic) {
        let phone = clinic.phoneNumber.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(phone)") {
            UIApplication.shared.open(url)
        }
    }

    private func getDirections(_ clinic: Clinic) {
        let destination = MKMapItem(location: CLLocation(latitude: clinic.latitude, longitude: clinic.longitude), address: nil)
        destination.name = clinic.name
        destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

struct ClinicDetailSheet: View {
    let clinic: Clinic
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            if clinic.isEmergency {
                                Text("EMERGENCY")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red)
                                    .clipShape(Capsule())
                            }

                            if clinic.is24Hours {
                                Text("24 HOURS")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green)
                                    .clipShape(Capsule())
                            }
                        }

                        Text(clinic.name)
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    // Map Preview
                    Map {
                        Marker(clinic.name, coordinate: clinic.coordinate)
                            .tint(.red)
                    }
                    .mapStyle(.standard)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Contact Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Contact Information")
                            .font(.headline)

                        ContactRow(icon: "mappin.circle.fill", title: "Address", value: "\(clinic.address)\n\(clinic.postcode)")
                        ContactRow(icon: "phone.fill", title: "Phone", value: clinic.phoneNumber)
                        if let email = clinic.email {
                            ContactRow(icon: "envelope.fill", title: "Email", value: email)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Services
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Services")
                            .font(.headline)

                        FlowLayout(spacing: 8) {
                            ForEach(clinic.services, id: \.self) { service in
                                Text(service)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundStyle(.blue)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Actions
                    VStack(spacing: 12) {
                        Button(action: { callClinic() }) {
                            Label("Call Clinic", systemImage: "phone.fill")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        Button(action: { getDirections() }) {
                            Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                                .font(.headline)
                                .foregroundStyle(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Clinic Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
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

struct ContactRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > width, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: width, height: y + rowHeight)
        }
    }
}

#Preview {
    ClinicFinderView()
        .environment(AppManager.shared)
}
