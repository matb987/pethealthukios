//
//  OnboardingView.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(AppManager.self) private var appManager
    @State private var currentPage = 0
    @State private var showingLogin = false
    @State private var showingRegister = false

    let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "pawprint.circle.fill",
            title: "Welcome to Pet_NHS",
            description: "Your pet's health partner. Access veterinary care across the UK with our network of partner clinics.",
            color: .blue
        ),
        OnboardingPage(
            image: "stethoscope",
            title: "Symptom Checker",
            description: "Get evidence-based guidance for common pet health issues. Know when to seek veterinary care.",
            color: .green
        ),
        OnboardingPage(
            image: "map.fill",
            title: "Find Clinics Near You",
            description: "Locate our partner clinics and emergency services. Book appointments with ease.",
            color: .purple
        ),
        OnboardingPage(
            image: "phone.fill",
            title: "24/7 Support",
            description: "Speak to a vet nurse anytime with our round-the-clock advice line. Help is always available.",
            color: .orange
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Page Content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Page Indicator
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            .padding(.bottom, 30)

            // Buttons
            VStack(spacing: 12) {
                if currentPage == pages.count - 1 {
                    Button(action: { showingRegister = true }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button(action: { showingLogin = true }) {
                        Text("I already have an account")
                            .font(.subheadline)
                            .foregroundStyle(Color.accentColor)
                    }
                    .padding(.top, 8)
                } else {
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        Text("Next")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button(action: {
                        withAnimation {
                            currentPage = pages.count - 1
                        }
                    }) {
                        Text("Skip")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showingLogin) {
            LoginView()
        }
        .sheet(isPresented: $showingRegister) {
            RegisterView()
        }
    }
}

struct OnboardingPage {
    let image: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: page.image)
                .font(.system(size: 100))
                .foregroundStyle(page.color)
                .padding()
                .background(
                    Circle()
                        .fill(page.color.opacity(0.1))
                        .frame(width: 180, height: 180)
                )

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
    }
}

struct LoginView: View {
    @Environment(AppManager.self) private var appManager
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo
                    VStack(spacing: 12) {
                        Image(systemName: "pawprint.circle.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(.blue)

                        Text("Pet_NHS")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                    // Form Fields
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            TextField("Enter your email", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            SecureField("Enter your password", text: $password)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                // Handle forgot password
                            }
                            .font(.caption)
                            .foregroundStyle(Color.accentColor)
                        }
                    }
                    .padding(.horizontal)

                    // Login Button
                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Log In")
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(email.isEmpty || password.isEmpty ? Color.gray : Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(email.isEmpty || password.isEmpty || isLoading)
                    .padding(.horizontal)

                    // Demo Login
                    VStack(spacing: 12) {
                        Text("or")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Button(action: demoLogin) {
                            Text("Continue with Demo Account")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.accentColor)
                        }
                    }

                    Spacer()
                }
            }
            .navigationTitle("Log In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func login() {
        isLoading = true

        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false

            // For demo purposes, accept any credentials
            let user = User(
                firstName: "User",
                lastName: "",
                email: email,
                phoneNumber: "",
                postcode: "",
                memberSince: Date(),
                subscriptionActive: true
            )
            appManager.login(user: user)
            appManager.completeOnboarding()
            dismiss()
        }
    }

    private func demoLogin() {
        appManager.loadDemoData()
        dismiss()
    }
}

struct RegisterView: View {
    @Environment(AppManager.self) private var appManager
    @Environment(\.dismiss) private var dismiss

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var postcode = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreedToTerms = false
    @State private var isLoading = false
    @State private var currentStep = 1

    var canProceedStep1: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty
    }

    var canProceedStep2: Bool {
        !postcode.isEmpty && !password.isEmpty && password == confirmPassword && agreedToTerms
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Indicator
                HStack(spacing: 8) {
                    ForEach(1...2, id: \.self) { step in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(step <= currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(height: 4)
                    }
                }
                .padding()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text(currentStep == 1 ? "Create Account" : "Almost There")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text(currentStep == 1 ? "Enter your personal details" : "Set up your password")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 20)

                        if currentStep == 1 {
                            step1Fields
                        } else {
                            step2Fields
                        }
                    }
                    .padding(.horizontal)
                }

                // Navigation Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        if currentStep == 1 {
                            currentStep = 2
                        } else {
                            register()
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(currentStep == 1 ? "Continue" : "Create Account")
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((currentStep == 1 ? canProceedStep1 : canProceedStep2) ? Color.accentColor : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(currentStep == 1 ? !canProceedStep1 : !canProceedStep2)
                    .disabled(isLoading)

                    if currentStep == 2 {
                        Button(action: { currentStep = 1 }) {
                            Text("Back")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Sign Up")
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

    private var step1Fields: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("First Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("First name", text: $firstName)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Last name", text: $lastName)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.subheadline)
                    .fontWeight(.medium)
                TextField("your@email.com", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Phone Number (Optional)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                TextField("07XXX XXXXXX", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var step2Fields: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Postcode")
                    .font(.subheadline)
                    .fontWeight(.medium)
                TextField("e.g., SW1A 1AA", text: $postcode)
                    .textInputAutocapitalization(.characters)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Text("We use this to find clinics near you")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline)
                    .fontWeight(.medium)
                SecureField("Create a password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.subheadline)
                    .fontWeight(.medium)
                SecureField("Confirm your password", text: $confirmPassword)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                if !confirmPassword.isEmpty && password != confirmPassword {
                    Text("Passwords don't match")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            // Terms Agreement
            Toggle(isOn: $agreedToTerms) {
                Text("I agree to the Terms of Service and Privacy Policy")
                    .font(.caption)
            }
            .toggleStyle(CheckboxToggleStyle())
            .padding(.top, 8)
        }
    }

    private func register() {
        isLoading = true

        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false

            let user = User(
                firstName: firstName,
                lastName: lastName,
                email: email,
                phoneNumber: phoneNumber,
                postcode: postcode,
                memberSince: Date(),
                subscriptionActive: true
            )
            appManager.login(user: user)
            appManager.completeOnboarding()
            dismiss()
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundStyle(configuration.isOn ? Color.accentColor : Color.secondary)
                .onTapGesture {
                    configuration.isOn.toggle()
                }

            configuration.label
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppManager.shared)
}
