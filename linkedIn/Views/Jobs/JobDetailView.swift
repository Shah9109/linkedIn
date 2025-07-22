import SwiftUI

struct JobDetailView: View {
    let job: Job
    let jobService: JobService
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showApplicationForm = false
    @State private var isSaved = false
    @State private var showShareSheet = false
    @State private var selectedTab = JobDetailTab.description
    
    private let tabs = JobDetailTab.allCases
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    headerSection
                    
                    // Tab Navigation
                    tabNavigationSection
                    
                    // Tab Content
                    tabContentSection
                }
            }
            .background(Constants.Colors.professionalGray)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showApplicationForm) {
            JobApplicationView(job: job, jobService: jobService)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [createShareText()])
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(Constants.Colors.label)
                        .padding(8)
                        .background(Constants.Colors.secondaryBackground)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                HStack(spacing: Constants.Spacing.md) {
                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .foregroundColor(Constants.Colors.label)
                            .padding(8)
                            .background(Constants.Colors.secondaryBackground)
                            .clipShape(Circle())
                    }
                    
                    Button(action: { 
                        isSaved.toggle()
                        if isSaved {
                            jobService.saveJob(job)
                        } else {
                            jobService.unsaveJob(job)
                        }
                    }) {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .font(.title3)
                            .foregroundColor(isSaved ? Constants.Colors.warning : Constants.Colors.label)
                            .padding(8)
                            .background(Constants.Colors.secondaryBackground)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.top, Constants.Spacing.sm)
            
            // Company and Job Info
            VStack(spacing: Constants.Spacing.md) {
                // Company Logo
                AsyncImage(url: URL(string: job.companyLogoURL ?? Constants.Images.companyLogo1)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                        .fill(Constants.Colors.lightGray)
                        .overlay(
                            Text(String(job.company.prefix(2)).uppercased())
                                .font(Constants.Fonts.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Constants.Colors.primaryBlue)
                        )
                }
                .frame(width: 80, height: 80)
                .cornerRadius(Constants.CornerRadius.medium)
                .shadow(color: Constants.Shadow.card.color, radius: 4, x: 0, y: 2)
                
                VStack(spacing: Constants.Spacing.sm) {
                    Text(job.title)
                        .font(Constants.Fonts.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.label)
                        .multilineTextAlignment(.center)
                    
                    Text(job.company)
                        .font(Constants.Fonts.title3)
                        .foregroundColor(Constants.Colors.primaryBlue)
                    
                    HStack {
                        Text(job.location)
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                        
                        if job.isRemote {
                            Text("• Remote")
                                .font(Constants.Fonts.body)
                                .foregroundColor(Constants.Colors.shareGreen)
                        }
                    }
                }
                
                // Job Type Tags
                HStack(spacing: Constants.Spacing.sm) {
                    jobTypeChip(
                        icon: job.workType.icon,
                        text: job.workType.title,
                        color: Constants.Colors.commentBlue
                    )
                    
                    jobTypeChip(
                        icon: "briefcase.fill",
                        text: job.employmentType.title,
                        color: Constants.Colors.shareGreen
                    )
                    
                    jobTypeChip(
                        icon: "person.fill",
                        text: job.experienceLevel.title,
                        color: Constants.Colors.sendPurple
                    )
                }
                
                // Salary Range
                if let salaryRange = job.salaryRange {
                    Text(salaryRange.formattedRange)
                        .font(Constants.Fonts.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.success)
                        .padding(.horizontal, Constants.Spacing.md)
                        .padding(.vertical, Constants.Spacing.sm)
                        .background(Constants.Colors.success.opacity(0.1))
                        .cornerRadius(Constants.CornerRadius.medium)
                }
                
                // Application Stats
                HStack(spacing: Constants.Spacing.lg) {
                    VStack {
                        Text("\(job.applicantCount)")
                            .font(Constants.Fonts.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Colors.label)
                        Text("Applicants")
                            .font(Constants.Fonts.caption1)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                    
                    Rectangle()
                        .fill(Constants.Colors.border)
                        .frame(width: 1, height: 30)
                    
                    VStack {
                        Text("\(job.views)")
                            .font(Constants.Fonts.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Colors.label)
                        Text("Views")
                            .font(Constants.Fonts.caption1)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                    
                    Rectangle()
                        .fill(Constants.Colors.border)
                        .frame(width: 1, height: 30)
                    
                    VStack {
                        Text(job.postedDate.timeAgoDisplay())
                            .font(Constants.Fonts.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Colors.label)
                        Text("Posted")
                            .font(Constants.Fonts.caption1)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                }
                .padding(.vertical, Constants.Spacing.md)
                
                // Apply Button
                Button(action: { showApplicationForm = true }) {
                    HStack {
                        if job.isEasyApply {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                        }
                        Text(job.isEasyApply ? "Easy Apply" : "Apply Now")
                            .font(Constants.Fonts.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Constants.Spacing.md)
                    .background(Constants.Colors.primaryBlue)
                    .cornerRadius(Constants.CornerRadius.large)
                }
                .padding(.horizontal, Constants.Spacing.lg)
            }
            .padding(Constants.Spacing.lg)
            .background(Constants.Colors.background)
        }
    }
    
    // MARK: - Tab Navigation Section
    private var tabNavigationSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        VStack(spacing: Constants.Spacing.xs) {
                            Text(tab.title)
                                .font(Constants.Fonts.body)
                                .fontWeight(.medium)
                                .foregroundColor(selectedTab == tab ? Constants.Colors.primaryBlue : Constants.Colors.secondaryLabel)
                            
                            Rectangle()
                                .fill(selectedTab == tab ? Constants.Colors.primaryBlue : Color.clear)
                                .frame(height: 2)
                        }
                        .padding(.horizontal, Constants.Spacing.lg)
                        .padding(.vertical, Constants.Spacing.sm)
                    }
                }
            }
        }
        .background(Constants.Colors.background)
        .overlay(
            Rectangle()
                .fill(Constants.Colors.border.opacity(0.3))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
    
    // MARK: - Tab Content Section
    private var tabContentSection: some View {
        Group {
            switch selectedTab {
            case .description:
                jobDescriptionTab
            case .company:
                companyInfoTab
            case .requirements:
                requirementsTab
            case .benefits:
                benefitsTab
            }
        }
        .padding(.top, Constants.Spacing.md)
    }
    
    // MARK: - Job Description Tab
    private var jobDescriptionTab: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
            jobDescriptionSection
            
            if !job.skills.isEmpty {
                skillsSection
            }
            
            if !job.responsibilities.isEmpty {
                responsibilitiesSection
            }
        }
        .padding(Constants.Spacing.md)
    }
    
    private var jobDescriptionSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Job Description")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            Text(job.description)
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.label)
                .lineSpacing(4)
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }
    
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Skills Required")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Constants.Spacing.sm) {
                ForEach(job.skills, id: \.self) { skill in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(Constants.Colors.success)
                        
                        Text(skill)
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.label)
                        
                        Spacer()
                    }
                    .padding(Constants.Spacing.sm)
                    .background(Constants.Colors.lightBlue.opacity(0.1))
                    .cornerRadius(Constants.CornerRadius.small)
                }
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }
    
    private var responsibilitiesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Key Responsibilities")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                ForEach(job.responsibilities, id: \.self) { responsibility in
                    HStack(alignment: .top) {
                        Text("•")
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.primaryBlue)
                            .padding(.top, 2)
                        
                        Text(responsibility)
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.label)
                            .lineSpacing(2)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }
    
    // MARK: - Company Info Tab
    private var companyInfoTab: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
            companyOverviewSection
            companyStatsSection
        }
        .padding(Constants.Spacing.md)
    }
    
    private var companyOverviewSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("About \(job.company)")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                HStack {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(Constants.Colors.primaryBlue)
                    Text("Industry: \(job.industry)")
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.label)
                }
                
                HStack {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(Constants.Colors.primaryBlue)
                    Text("Company Size: \(job.companySize.title)")
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.label)
                }
                
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(Constants.Colors.primaryBlue)
                    Text("Headquarters: \(job.location)")
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.label)
                }
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }
    
    private var companyStatsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Company Insights")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            HStack(spacing: Constants.Spacing.lg) {
                VStack {
                    Text("4.2")
                        .font(Constants.Fonts.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.success)
                    Text("Rating")
                        .font(Constants.Fonts.caption1)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < 4 ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(Constants.Colors.warning)
                        }
                    }
                }
                
                Spacer()
                
                VStack {
                    Text("1.2K")
                        .font(Constants.Fonts.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.primaryBlue)
                    Text("Employees")
                        .font(Constants.Fonts.caption1)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                }
                
                Spacer()
                
                VStack {
                    Text("24")
                        .font(Constants.Fonts.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.sendPurple)
                    Text("Open Jobs")
                        .font(Constants.Fonts.caption1)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                }
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }
    
    // MARK: - Requirements Tab
    private var requirementsTab: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
            if !job.requirements.isEmpty {
                requirementsSection
            }
            
            qualificationsSection
        }
        .padding(Constants.Spacing.md)
    }
    
    private var requirementsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Requirements")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                ForEach(job.requirements, id: \.self) { requirement in
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.circle")
                            .font(.body)
                            .foregroundColor(Constants.Colors.success)
                            .padding(.top, 2)
                        
                        Text(requirement)
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.label)
                            .lineSpacing(2)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }
    
    private var qualificationsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Preferred Qualifications")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                qualificationItem("Experience Level", job.experienceLevel.title, "person.badge.clock")
                qualificationItem("Work Type", job.workType.title, job.workType.icon)
                qualificationItem("Employment Type", job.employmentType.title, "briefcase")
                if job.isRemote {
                    qualificationItem("Remote Work", "Available", "house")
                }
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }
    
    private func qualificationItem(_ title: String, _ value: String, _ icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(Constants.Colors.primaryBlue)
                .frame(width: 20)
            
            Text(title)
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.secondaryLabel)
            
            Spacer()
            
            Text(value)
                .font(Constants.Fonts.body)
                .fontWeight(.medium)
                .foregroundColor(Constants.Colors.label)
        }
        .padding(.vertical, Constants.Spacing.xs)
    }
    
    // MARK: - Benefits Tab
    private var benefitsTab: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.lg) {
            if !job.benefits.isEmpty {
                benefitsSection
            }
            
            additionalPerksSection
        }
        .padding(Constants.Spacing.md)
    }
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Benefits & Perks")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: Constants.Spacing.sm) {
                ForEach(job.benefits, id: \.self) { benefit in
                    HStack {
                        Image(systemName: getBenefitIcon(benefit))
                            .font(.title3)
                            .foregroundColor(Constants.Colors.success)
                            .frame(width: 24)
                        
                        Text(benefit)
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.label)
                        
                        Spacer()
                    }
                    .padding(Constants.Spacing.md)
                    .background(Constants.Colors.success.opacity(0.05))
                    .cornerRadius(Constants.CornerRadius.medium)
                }
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }
    
    private var additionalPerksSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Work Environment")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            VStack(spacing: Constants.Spacing.sm) {
                workEnvironmentItem("Collaborative Team", "work closely with talented professionals", "person.3.fill")
                workEnvironmentItem("Growth Opportunities", "Learn and advance your career", "chart.line.uptrend.xyaxis")
                workEnvironmentItem("Innovation Focus", "Work on cutting-edge projects", "lightbulb.fill")
                workEnvironmentItem("Work-Life Balance", "Flexible schedule and remote options", "scale.3d")
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
    }
    
    private func workEnvironmentItem(_ title: String, _ description: String, _ icon: String) -> some View {
        HStack(alignment: .top, spacing: Constants.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Constants.Colors.primaryBlue)
                .frame(width: 24)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                Text(title)
                    .font(Constants.Fonts.body)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.label)
                
                Text(description)
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.secondaryLabel)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Helper Views
    private func jobTypeChip(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: Constants.Spacing.xs) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(Constants.Fonts.caption1)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.vertical, Constants.Spacing.sm)
        .background(color.opacity(0.1))
        .cornerRadius(Constants.CornerRadius.pill)
    }
    
    // MARK: - Helper Methods
    private func getBenefitIcon(_ benefit: String) -> String {
        switch benefit.lowercased() {
        case let b where b.contains("health") || b.contains("medical"):
            return "heart.fill"
        case let b where b.contains("401") || b.contains("retirement"):
            return "banknote.fill"
        case let b where b.contains("pto") || b.contains("vacation"):
            return "calendar"
        case let b where b.contains("development") || b.contains("learning"):
            return "book.fill"
        case let b where b.contains("gym") || b.contains("wellness"):
            return "figure.strengthtraining.traditional"
        case let b where b.contains("meals") || b.contains("food"):
            return "fork.knife"
        default:
            return "checkmark.circle.fill"
        }
    }
    
    private func createShareText() -> String {
        return "Check out this job opportunity: \(job.title) at \(job.company)\n\nLocation: \(job.location)\nType: \(job.employmentType.title)\n\n\(job.description)"
    }
}

// MARK: - Job Detail Tabs
enum JobDetailTab: String, CaseIterable {
    case description = "description"
    case company = "company"
    case requirements = "requirements"
    case benefits = "benefits"
    
    var title: String {
        switch self {
        case .description:
            return "Description"
        case .company:
            return "Company"
        case .requirements:
            return "Requirements"
        case .benefits:
            return "Benefits"
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    JobDetailView(
        job: Job(
            title: "Senior iOS Developer",
            company: "TechCorp",
            location: "San Francisco, CA",
            workType: .hybrid,
            employmentType: .fullTime,
            experienceLevel: .senior,
            description: "We are looking for a Senior iOS Developer to join our team...",
            industry: "Technology",
            jobPosterUserId: "123",
            jobPosterName: "HR Team"
        ),
        jobService: JobService()
    )
} 