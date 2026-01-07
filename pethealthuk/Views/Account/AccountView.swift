//
//  AccountView.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import SwiftUI

struct AccountView: View {
    @Environment(AppManager.self) private var appManager
    @State private var showingLogoutAlert = false
    @State private var showingEditProfile = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    profileHeader

                    // Subscription Status
                    subscriptionCard

                    // Account Options
                    accountOptionsSection

                    // Support Section
                    supportSection

                    // App Info
                    appInfoSection

                    // Logout Button
                    logoutButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Account")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    appManager.logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            if let user = appManager.currentUser {
                VStack(spacing: 4) {
                    Text(user.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Button(action: { showingEditProfile = true }) {
                    Text("Edit Profile")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            } else {
                Text("Guest User")
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var subscriptionCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(.green)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Pet_NHS Member")
                        .font(.headline)
                    Text(appManager.currentUser?.subscriptionActive == true ? "Active Subscription" : "Inactive")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("Active")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .clipShape(Capsule())
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Member Since")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let user = appManager.currentUser {
                        Text(user.memberSince.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }

                Spacer()

                Button(action: {}) {
                    Text("Manage")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var accountOptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account")
                .font(.headline)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                AccountOptionRow(icon: "person.fill", title: "Personal Information", color: .blue) {
                    showingEditProfile = true
                }
                Divider().padding(.leading, 52)

                AccountOptionRow(icon: "bell.fill", title: "Notifications", color: .orange) {
                    // Navigate to notifications settings
                }
                Divider().padding(.leading, 52)

                AccountOptionRow(icon: "lock.fill", title: "Privacy & Security", color: .green) {
                    // Navigate to privacy settings
                }
                Divider().padding(.leading, 52)

                AccountOptionRow(icon: "creditcard.fill", title: "Payment Methods", color: .purple) {
                    // Navigate to payment methods
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support")
                .font(.headline)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                AccountOptionRow(icon: "questionmark.circle.fill", title: "Help Centre", color: .blue) {
                    // Open help centre
                }
                Divider().padding(.leading, 52)

                AccountOptionRow(icon: "phone.fill", title: "Contact Us", color: .green) {
                    callSupport()
                }
                Divider().padding(.leading, 52)

                AccountOptionRow(icon: "doc.text.fill", title: "Terms & Conditions", color: .gray) {
                    // Open terms
                }
                Divider().padding(.leading, 52)

                AccountOptionRow(icon: "hand.raised.fill", title: "Privacy Policy", color: .gray) {
                    // Open privacy policy
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var appInfoSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "pawprint.fill")
                .font(.title)
                .foregroundStyle(.blue)

            Text("Pet_NHS")
                .font(.headline)

            Text("Version 1.0.0")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("© 2025 PetHealthUK")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    private var logoutButton: some View {
        Button(action: { showingLogoutAlert = true }) {
            Text("Log Out")
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func callSupport() {
        if let url = URL(string: "tel://08000001111") {
            UIApplication.shared.open(url)
        }
    }
}

struct AccountOptionRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 28)

                Text(title)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}

struct EditProfileView: View {
    @Environment(AppManager.self) private var appManager
    @Environment(\.dismiss) private var dismiss

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var postcode: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }

                Section("Address") {
                    TextField("Postcode", text: $postcode)
                        .textInputAutocapitalization(.characters)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty || email.isEmpty)
                }
            }
            .onAppear {
                loadProfile()
            }
        }
    }

    private func loadProfile() {
        if let user = appManager.currentUser {
            firstName = user.firstName
            lastName = user.lastName
            email = user.email
            phoneNumber = user.phoneNumber
            postcode = user.postcode
        }
    }

    private func saveProfile() {
        if var user = appManager.currentUser {
            user.firstName = firstName
            user.lastName = lastName
            user.email = email
            user.phoneNumber = phoneNumber
            user.postcode = postcode
            appManager.login(user: user)
        }
        dismiss()
    }
}

#Preview {
    AccountView()
        .environment(AppManager.shared)
}
