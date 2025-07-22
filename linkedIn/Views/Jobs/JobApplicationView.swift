import SwiftUI

struct JobApplicationView: View {
    let job: Job
    let jobService: JobService
    
    @Environment(\.presentationMode) var presentationMode
    @State private var coverLetter = ""
    @State private var resumeURL = ""
    @State private var hasResume = false
    @State private var showingSuccess = false
    @State private var isSubmitting = false
    @State private var selectedApplicationType: ApplicationType = .quickApply
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.Spacing.lg) {
                    // Job Header
                    jobHeaderSection
                    
                    // Application Type Selection
                    applicationTypeSection
                    
                    // Application Form
                    if selectedApplicationType == .detailed {
                        detailedApplicationForm
                    } else {
                        quickApplyForm
                    }
                    
                    // Submit Button
                    submitButtonSection
                }
                .padding(Constants.Spacing.md)
            }
            .background(Constants.Colors.professionalGray)
            .navigationTitle("Apply for Job")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .alert("Application Submitted!", isPresented: $showingSuccess) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your application has been successfully submitted to \(job.company). They will review your application and get back to you soon.")
        }
    }
    
    // MARK: - Job Header Section
    private var jobHeaderSection: some View {
        VStack(spacing: Constants.Spacing.md) {
            HStack {
                AsyncImage(url: URL(string: job.companyLogoURL ?? Constants.Images.companyLogo1)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                        .fill(Constants.Colors.lightGray)
                        .overlay(
                            Text(String(job.company.prefix(2)).uppercased())
                                .font(Constants.Fonts.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Constants.Colors.primaryBlue)
                        )
                }
                .frame(width: 60, height: 60)
                .cornerRadius(Constants.CornerRadius.medium)
                
                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    Text(job.title)
                        .font(Constants.Fonts.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.label)
                    
                    Text(job.company)
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.primaryBlue)
                    
                    Text(job.location)
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                }
                
                Spacer()
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
        .shadow(
            color: Constants.Shadow.card.color,
            radius: Constants.Shadow.card.radius,
            x: Constants.Shadow.card.x,
            y: Constants.Shadow.card.y
        )
    }
    
    // MARK: - Application Type Section
    private var applicationTypeSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Application Type")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            VStack(spacing: Constants.Spacing.sm) {
                ApplicationTypeCard(
                    type: .quickApply,
                    isSelected: selectedApplicationType == .quickApply,
                    onSelect: { selectedApplicationType = .quickApply }
                )
                
                ApplicationTypeCard(
                    type: .detailed,
                    isSelected: selectedApplicationType == .detailed,
                    onSelect: { selectedApplicationType = .detailed }
                )
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
        .shadow(
            color: Constants.Shadow.card.color,
            radius: Constants.Shadow.card.radius,
            x: Constants.Shadow.card.x,
            y: Constants.Shadow.card.y
        )
    }
    
    // MARK: - Quick Apply Form
    private var quickApplyForm: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Quick Apply")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            Text("Your ProNet profile will be used for this application. Make sure your profile is up to date.")
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.secondaryLabel)
            
            // Profile Summary
            if let currentUser = FirebaseManager.shared.currentUser {
                VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                    Text("Profile Summary")
                        .font(Constants.Fonts.body)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.label)
                    
                    HStack {
                        AsyncImage(url: URL(string: currentUser.profileImageURL ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Constants.Colors.lightGray)
                                .overlay(
                                    Text(currentUser.initials)
                                        .font(Constants.Fonts.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(Constants.Colors.primaryBlue)
                                )
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                            Text(currentUser.fullName)
                                .font(Constants.Fonts.body)
                                .fontWeight(.medium)
                                .foregroundColor(Constants.Colors.label)
                            
                            Text(currentUser.headline ?? "Professional")
                                .font(Constants.Fonts.caption1)
                                .foregroundColor(Constants.Colors.secondaryLabel)
                                .lineLimit(2)
                            
                            Text(currentUser.email)
                                .font(Constants.Fonts.caption1)
                                .foregroundColor(Constants.Colors.primaryBlue)
                        }
                        
                        Spacer()
                    }
                }
                .padding(Constants.Spacing.md)
                .background(Constants.Colors.lightBlue.opacity(0.1))
                .cornerRadius(Constants.CornerRadius.medium)
            }
            
            // Optional message
            VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                Text("Optional Message (Optional)")
                    .font(Constants.Fonts.body)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.label)
                
                TextEditor(text: $coverLetter)
                    .frame(height: 80)
                    .padding(Constants.Spacing.sm)
                    .background(Constants.Colors.secondaryBackground)
                    .cornerRadius(Constants.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                            .stroke(Constants.Colors.border.opacity(0.3), lineWidth: 1)
                    )
                
                if coverLetter.isEmpty {
                    Text("Why are you interested in this role? (Optional)")
                        .font(Constants.Fonts.caption1)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                        .padding(.leading, Constants.Spacing.sm)
                        .offset(y: -85)
                        .allowsHitTesting(false)
                }
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
        .shadow(
            color: Constants.Shadow.card.color,
            radius: Constants.Shadow.card.radius,
            x: Constants.Shadow.card.x,
            y: Constants.Shadow.card.y
        )
    }
    
    // MARK: - Detailed Application Form
    private var detailedApplicationForm: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
            // Cover Letter Section
            VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                Text("Cover Letter")
                    .font(Constants.Fonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Text("Tell them why you're the perfect fit for this role.")
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                
                TextEditor(text: $coverLetter)
                    .frame(height: 120)
                    .padding(Constants.Spacing.sm)
                    .background(Constants.Colors.secondaryBackground)
                    .cornerRadius(Constants.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                            .stroke(Constants.Colors.border.opacity(0.3), lineWidth: 1)
                    )
                
                if coverLetter.isEmpty {
                    Text("Dear Hiring Manager,\n\nI am excited to apply for the \(job.title) position at \(job.company)...")
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.secondaryLabel.opacity(0.7))
                        .padding(.leading, Constants.Spacing.sm)
                        .offset(y: -125)
                        .allowsHitTesting(false)
                }
                
                Text("\(coverLetter.count)/500 characters")
                    .font(Constants.Fonts.caption2)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(Constants.Spacing.cardPadding)
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.CornerRadius.card)
            .shadow(
                color: Constants.Shadow.card.color,
                radius: Constants.Shadow.card.radius,
                x: Constants.Shadow.card.x,
                y: Constants.Shadow.card.y
            )
            
            // Resume Section
            VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                Text("Resume")
                    .font(Constants.Fonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                VStack(spacing: Constants.Spacing.md) {
                    Toggle("I have a resume to upload", isOn: $hasResume)
                        .toggleStyle(SwitchToggleStyle(tint: Constants.Colors.primaryBlue))
                    
                    if hasResume {
                        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                            Text("Resume URL or File Path")
                                .font(Constants.Fonts.body)
                                .fontWeight(.medium)
                                .foregroundColor(Constants.Colors.label)
                            
                            TextField("Enter resume URL or select file", text: $resumeURL)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Select File") {
                                // File picker functionality would go here
                                resumeURL = "https://example.com/resume.pdf"
                            }
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.primaryBlue)
                            .padding(.horizontal, Constants.Spacing.md)
                            .padding(.vertical, Constants.Spacing.sm)
                            .background(Constants.Colors.lightBlue.opacity(0.2))
                            .cornerRadius(Constants.CornerRadius.medium)
                        }
                    }
                }
            }
            .padding(Constants.Spacing.cardPadding)
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.CornerRadius.card)
            .shadow(
                color: Constants.Shadow.card.color,
                radius: Constants.Shadow.card.radius,
                x: Constants.Shadow.card.x,
                y: Constants.Shadow.card.y
            )
        }
    }
    
    // MARK: - Submit Button Section
    private var submitButtonSection: some View {
        VStack(spacing: Constants.Spacing.md) {
            Button(action: submitApplication) {
                HStack {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Text(isSubmitting ? "Submitting..." : "Submit Application")
                        .font(Constants.Fonts.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Constants.Spacing.md)
                .background(canSubmit ? Constants.Colors.primaryBlue : Constants.Colors.border)
                .cornerRadius(Constants.CornerRadius.large)
            }
            .disabled(!canSubmit || isSubmitting)
            
            Text("By submitting, you agree to share your profile information with \(job.company).")
                .font(Constants.Fonts.caption1)
                .foregroundColor(Constants.Colors.secondaryLabel)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Computed Properties
    private var canSubmit: Bool {
        if selectedApplicationType == .quickApply {
            return true // Quick apply always allowed
        } else {
            return !coverLetter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    // MARK: - Helper Methods
    private func submitApplication() {
        isSubmitting = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            jobService.applyToJob(
                job,
                coverLetter: coverLetter.isEmpty ? nil : coverLetter,
                resumeURL: hasResume && !resumeURL.isEmpty ? resumeURL : nil
            )
            
            isSubmitting = false
            showingSuccess = true
        }
    }
}

// MARK: - Application Type Enum
enum ApplicationType {
    case quickApply
    case detailed
    
    var title: String {
        switch self {
        case .quickApply:
            return "Quick Apply"
        case .detailed:
            return "Detailed Application"
        }
    }
    
    var subtitle: String {
        switch self {
        case .quickApply:
            return "Apply with your ProNet profile in one click"
        case .detailed:
            return "Submit a personalized cover letter and resume"
        }
    }
    
    var icon: String {
        switch self {
        case .quickApply:
            return "bolt.fill"
        case .detailed:
            return "doc.text.fill"
        }
    }
    
    var benefits: [String] {
        switch self {
        case .quickApply:
            return ["Instant application", "Uses your profile", "No additional steps"]
        case .detailed:
            return ["Personal touch", "Stand out from crowd", "Show genuine interest"]
        }
    }
}

// MARK: - Application Type Card
struct ApplicationTypeCard: View {
    let type: ApplicationType
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                HStack {
                    Image(systemName: type.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? Constants.Colors.primaryBlue : Constants.Colors.secondaryLabel)
                    
                    VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                        Text(type.title)
                            .font(Constants.Fonts.body)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.label)
                        
                        Text(type.subtitle)
                            .font(Constants.Fonts.caption1)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(isSelected ? Constants.Colors.primaryBlue : Constants.Colors.border)
                }
                
                if isSelected {
                    VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                        ForEach(type.benefits, id: \.self) { benefit in
                            HStack {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .foregroundColor(Constants.Colors.success)
                                
                                Text(benefit)
                                    .font(Constants.Fonts.caption1)
                                    .foregroundColor(Constants.Colors.secondaryLabel)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, Constants.Spacing.sm)
                }
            }
            .padding(Constants.Spacing.md)
            .background(isSelected ? Constants.Colors.lightBlue.opacity(0.1) : Constants.Colors.secondaryBackground)
            .cornerRadius(Constants.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .stroke(isSelected ? Constants.Colors.primaryBlue : Constants.Colors.border.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    JobApplicationView(
        job: Job(
            title: "Senior iOS Developer",
            company: "TechCorp",
            location: "San Francisco, CA",
            workType: .hybrid,
            employmentType: .fullTime,
            experienceLevel: .senior,
            description: "We are looking for a Senior iOS Developer...",
            industry: "Technology",
            jobPosterUserId: "123",
            jobPosterName: "HR Team"
        ),
        jobService: JobService()
    )
} 