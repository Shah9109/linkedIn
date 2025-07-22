import SwiftUI

struct JobsView: View {
    @StateObject private var jobService = JobService()
    @State private var searchText = ""
    @State private var showFilters = false
    @State private var selectedFilter = JobFilter.all
    @State private var filters = JobSearchFilters()
    @State private var selectedJob: Job?
    @State private var showJobDetails = false
    
    private let jobFilters = JobFilter.allCases
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with search
                headerSection
                
                // Filter tabs
                filterTabsSection
                
                // Content
                contentSection
            }
            .background(Constants.Colors.professionalGray)
            .navigationBarHidden(true)
            .onAppear {
                if jobService.jobs.isEmpty {
                    jobService.searchJobs()
                }
                jobService.getFeaturedJobs()
            }
        }
        .sheet(isPresented: $showFilters) {
            JobFiltersView(filters: $filters) { appliedFilters in
                jobService.searchJobs(filters: appliedFilters)
            }
        }
        .sheet(item: $selectedJob) { job in
            JobDetailView(job: job, jobService: jobService)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: Constants.Spacing.md) {
            HStack {
                Text("Jobs")
                    .font(Constants.Fonts.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.label)
                
                Spacer()
                
                HStack(spacing: Constants.Spacing.md) {
                    Button(action: { showFilters = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title3)
                            .foregroundColor(Constants.Colors.primaryBlue)
                    }
                    
                    Button(action: { /* Show saved jobs */ }) {
                        Image(systemName: "bookmark.circle")
                            .font(.title3)
                            .foregroundColor(Constants.Colors.primaryBlue)
                    }
                }
            }
            
            // Enhanced Search Bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Constants.Colors.secondaryLabel)
                        .font(.callout)
                    
                    TextField("Search jobs, companies, skills", text: $searchText)
                        .font(Constants.Fonts.body)
                        .onSubmit {
                            searchJobs()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: { 
                            searchText = ""
                            searchJobs()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Constants.Colors.secondaryLabel)
                        }
                    }
                }
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.sm)
                .background(Constants.Colors.secondaryBackground)
                .cornerRadius(Constants.CornerRadius.pill)
                
                Button("Search") {
                    searchJobs()
                }
                .font(Constants.Fonts.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.sm)
                .background(Constants.Colors.primaryBlue)
                .cornerRadius(Constants.CornerRadius.pill)
            }
        }
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.top, Constants.Spacing.md)
        .padding(.bottom, Constants.Spacing.sm)
        .background(Constants.Colors.background)
    }
    
    // MARK: - Filter Tabs Section
    private var filterTabsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Spacing.md) {
                ForEach(jobFilters, id: \.self) { filter in
                    filterTab(filter)
                }
            }
            .padding(.horizontal, Constants.Spacing.md)
        }
        .padding(.vertical, Constants.Spacing.sm)
        .background(Constants.Colors.background)
        .overlay(
            Rectangle()
                .fill(Constants.Colors.border.opacity(0.3))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
    
    private func filterTab(_ filter: JobFilter) -> some View {
        Button(action: { 
            selectedFilter = filter
            applyQuickFilter(filter)
        }) {
            HStack(spacing: Constants.Spacing.xs) {
                if filter != .all {
                    Image(systemName: filter.icon)
                        .font(.caption)
                }
                
                Text(filter.title)
                    .font(Constants.Fonts.body)
                    .fontWeight(.medium)
                
                if filter != .all {
                    Text("\(getJobCount(for: filter))")
                        .font(Constants.Fonts.caption2)
                        .padding(.horizontal, Constants.Spacing.xs)
                        .padding(.vertical, 2)
                        .background(selectedFilter == filter ? .white : Constants.Colors.primaryBlue)
                        .foregroundColor(selectedFilter == filter ? Constants.Colors.primaryBlue : .white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.vertical, Constants.Spacing.sm)
            .background(selectedFilter == filter ? Constants.Colors.primaryBlue : Constants.Colors.secondaryBackground)
            .foregroundColor(selectedFilter == filter ? .white : Constants.Colors.label)
            .cornerRadius(Constants.CornerRadius.pill)
        }
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        Group {
            if jobService.isLoading && jobService.jobs.isEmpty {
                loadingSection
            } else if jobService.jobs.isEmpty {
                emptyStateSection
            } else {
                jobListSection
            }
        }
    }
    
    // MARK: - Job List Section
    private var jobListSection: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Featured Jobs Section (only for "All" filter)
                if selectedFilter == .all && !jobService.featuredJobs.isEmpty {
                    featuredJobsSection
                }
                
                // Job Cards
                ForEach(jobService.jobs, id: \.id) { job in
                    JobCardView(job: job, onTap: {
                        selectedJob = job
                    }, onSave: {
                        jobService.saveJob(job)
                    }, onApply: {
                        // Quick apply functionality
                        jobService.applyToJob(job)
                    })
                    .onAppear {
                        // Load more when near the end
                        if job.id == jobService.jobs.last?.id {
                            jobService.loadMoreJobs()
                        }
                    }
                }
                
                // Loading more indicator
                if jobService.isLoading {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.primaryBlue))
                        Text("Loading more jobs...")
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                    .padding(Constants.Spacing.lg)
                }
            }
        }
        .refreshable {
            await refreshJobs()
        }
    }
    
    // MARK: - Featured Jobs Section
    private var featuredJobsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Text("Featured Jobs")
                    .font(Constants.Fonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Spacer()
                
                Button("See all") {
                    selectedFilter = .featured
                    applyQuickFilter(.featured)
                }
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            .padding(.horizontal, Constants.Spacing.md)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.md) {
                    ForEach(jobService.featuredJobs, id: \.id) { job in
                        FeaturedJobCardView(job: job) {
                            selectedJob = job
                        }
                    }
                }
                .padding(.horizontal, Constants.Spacing.md)
            }
        }
        .padding(.vertical, Constants.Spacing.md)
        .background(Constants.Colors.background)
    }
    
    // MARK: - Loading Section
    private var loadingSection: some View {
        ScrollView {
            LazyVStack(spacing: Constants.Spacing.md) {
                ForEach(0..<6, id: \.self) { _ in
                    JobCardSkeletonView()
                }
            }
            .padding(Constants.Spacing.md)
        }
    }
    
    // MARK: - Empty State Section
    private var emptyStateSection: some View {
        VStack(spacing: Constants.Spacing.lg) {
            Image(systemName: "briefcase.circle")
                .font(.system(size: 64))
                .foregroundColor(Constants.Colors.secondaryLabel)
            
            VStack(spacing: Constants.Spacing.sm) {
                Text("No jobs found")
                    .font(Constants.Fonts.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Text("Try adjusting your search criteria or filters to find more opportunities.")
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: Constants.Spacing.md) {
                Button("Clear Filters") {
                    clearFilters()
                }
                .font(Constants.Fonts.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, Constants.Spacing.lg)
                .padding(.vertical, Constants.Spacing.sm)
                .background(Constants.Colors.primaryBlue)
                .cornerRadius(Constants.CornerRadius.pill)
                
                Button("Browse All Jobs") {
                    selectedFilter = .all
                    clearFilters()
                }
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.primaryBlue)
            }
        }
        .padding(.horizontal, Constants.Spacing.lg)
        .padding(.top, Constants.Spacing.xxl)
    }
    
    // MARK: - Helper Methods
    private func searchJobs() {
        filters.keywords = searchText
        jobService.searchJobs(filters: filters)
    }
    
    private func applyQuickFilter(_ filter: JobFilter) {
        switch filter {
        case .all:
            clearFilters()
        case .remote:
            filters.isRemoteOnly = true
            filters.workTypes = [.remote]
        case .fullTime:
            filters.employmentTypes = [.fullTime]
        case .partTime:
            filters.employmentTypes = [.partTime]
        case .contract:
            filters.employmentTypes = [.contract]
        case .recent:
            filters.postedWithin = .pastWeek
        case .easyApply:
            filters.isEasyApplyOnly = true
        case .featured:
            // Show featured jobs - handled in job service
            break
        }
        
        if filter != .all {
            jobService.searchJobs(filters: filters)
        }
    }
    
    private func clearFilters() {
        searchText = ""
        filters = JobSearchFilters()
        selectedFilter = .all
        jobService.searchJobs()
    }
    
    private func getJobCount(for filter: JobFilter) -> Int {
        // Simulate job counts for each filter
        switch filter {
        case .all: return jobService.jobs.count
        case .remote: return Int.random(in: 50...200)
        case .fullTime: return Int.random(in: 100...300)
        case .partTime: return Int.random(in: 20...80)
        case .contract: return Int.random(in: 30...100)
        case .recent: return Int.random(in: 25...75)
        case .easyApply: return Int.random(in: 80...250)
        case .featured: return jobService.featuredJobs.count
        }
    }
    
    @MainActor
    private func refreshJobs() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        jobService.searchJobs(filters: filters)
    }
}

// MARK: - Job Filter Enum
enum JobFilter: String, CaseIterable {
    case all = "all"
    case remote = "remote"
    case fullTime = "full_time"
    case partTime = "part_time"
    case contract = "contract"
    case recent = "recent"
    case easyApply = "easy_apply"
    case featured = "featured"
    
    var title: String {
        switch self {
        case .all: return "All"
        case .remote: return "Remote"
        case .fullTime: return "Full-time"
        case .partTime: return "Part-time"
        case .contract: return "Contract"
        case .recent: return "Recent"
        case .easyApply: return "Easy Apply"
        case .featured: return "Featured"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "briefcase"
        case .remote: return "house.fill"
        case .fullTime: return "clock.fill"
        case .partTime: return "clock.badge"
        case .contract: return "doc.text.fill"
        case .recent: return "clock.arrow.circlepath"
        case .easyApply: return "checkmark.circle.fill"
        case .featured: return "star.fill"
        }
    }
}

// MARK: - Job Card View
struct JobCardView: View {
    let job: Job
    let onTap: () -> Void
    let onSave: () -> Void
    let onApply: () -> Void
    
    @State private var isSaved = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                // Header with company info
                HStack(alignment: .top) {
                    // Company logo
                    AsyncImage(url: URL(string: job.companyLogoURL ?? Constants.Images.companyLogo1)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: Constants.CornerRadius.small)
                            .fill(Constants.Colors.lightGray)
                            .overlay(
                                Text(String(job.company.prefix(2)).uppercased())
                                    .font(Constants.Fonts.caption1)
                                    .fontWeight(.bold)
                                    .foregroundColor(Constants.Colors.primaryBlue)
                            )
                    }
                    .frame(width: 48, height: 48)
                    .cornerRadius(Constants.CornerRadius.small)
                    
                    VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                        Text(job.title)
                            .font(Constants.Fonts.professionalHeadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.label)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        Text(job.company)
                            .font(Constants.Fonts.body)
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
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: Constants.Spacing.xs) {
                        Button(action: { 
                            isSaved.toggle()
                            onSave()
                        }) {
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                .font(.title3)
                                .foregroundColor(isSaved ? Constants.Colors.warning : Constants.Colors.secondaryLabel)
                        }
                        
                        Text(job.postedDate.timeAgoDisplay())
                            .font(Constants.Fonts.caption2)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                }
                
                // Job details
                HStack {
                    jobDetailChip(
                        icon: job.workType.icon,
                        text: job.workType.title,
                        color: Constants.Colors.commentBlue
                    )
                    
                    jobDetailChip(
                        icon: "briefcase.fill",
                        text: job.employmentType.title,
                        color: Constants.Colors.shareGreen
                    )
                    
                    jobDetailChip(
                        icon: "person.fill",
                        text: job.experienceLevel.title,
                        color: Constants.Colors.sendPurple
                    )
                    
                    Spacer()
                }
                
                // Salary range
                if let salaryRange = job.salaryRange {
                    Text(salaryRange.formattedRange)
                        .font(Constants.Fonts.body)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.success)
                }
                
                // Skills tags
                if !job.skills.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Constants.Spacing.xs) {
                            ForEach(job.skills.prefix(4), id: \.self) { skill in
                                Text(skill)
                                    .font(Constants.Fonts.caption1)
                                    .padding(.horizontal, Constants.Spacing.sm)
                                    .padding(.vertical, Constants.Spacing.xs)
                                    .background(Constants.Colors.lightBlue.opacity(0.2))
                                    .foregroundColor(Constants.Colors.primaryBlue)
                                    .cornerRadius(Constants.CornerRadius.small)
                            }
                            
                            if job.skills.count > 4 {
                                Text("+\(job.skills.count - 4)")
                                    .font(Constants.Fonts.caption2)
                                    .foregroundColor(Constants.Colors.secondaryLabel)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Footer with application info
                HStack {
                    HStack(spacing: Constants.Spacing.xs) {
                        Image(systemName: "person.2")
                            .font(.caption)
                        Text("\(job.applicantCount) applicants")
                            .font(Constants.Fonts.caption1)
                    }
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    
                    Spacer()
                    
                    if job.isEasyApply {
                        Text("Easy Apply")
                            .font(Constants.Fonts.caption1)
                            .fontWeight(.medium)
                            .foregroundColor(Constants.Colors.success)
                            .padding(.horizontal, Constants.Spacing.sm)
                            .padding(.vertical, 2)
                            .background(Constants.Colors.success.opacity(0.1))
                            .cornerRadius(Constants.CornerRadius.small)
                    }
                    
                    if job.isUrgent {
                        Text("Urgent")
                            .font(Constants.Fonts.caption1)
                            .fontWeight(.medium)
                            .foregroundColor(Constants.Colors.error)
                            .padding(.horizontal, Constants.Spacing.sm)
                            .padding(.vertical, 2)
                            .background(Constants.Colors.error.opacity(0.1))
                            .cornerRadius(Constants.CornerRadius.small)
                    }
                    
                    Button("Apply") {
                        onApply()
                    }
                    .font(Constants.Fonts.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, Constants.Spacing.md)
                    .padding(.vertical, Constants.Spacing.xs)
                    .background(Constants.Colors.primaryBlue)
                    .cornerRadius(Constants.CornerRadius.pill)
                }
            }
            .padding(Constants.Spacing.cardPadding)
        }
        .buttonStyle(PlainButtonStyle())
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
        .shadow(
            color: Constants.Shadow.card.color,
            radius: Constants.Shadow.card.radius,
            x: Constants.Shadow.card.x,
            y: Constants.Shadow.card.y
        )
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.vertical, Constants.Spacing.xs)
    }
    
    private func jobDetailChip(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: Constants.Spacing.xs) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(Constants.Fonts.caption1)
        }
        .foregroundColor(color)
        .padding(.horizontal, Constants.Spacing.sm)
        .padding(.vertical, Constants.Spacing.xs)
        .background(color.opacity(0.1))
        .cornerRadius(Constants.CornerRadius.small)
    }
}

// MARK: - Featured Job Card View
struct FeaturedJobCardView: View {
    let job: Job
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                        Text(job.title)
                            .font(Constants.Fonts.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.label)
                            .lineLimit(2)
                        
                        Text(job.company)
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.primaryBlue)
                        
                        Text(job.location)
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "star.fill")
                        .font(.title3)
                        .foregroundColor(Constants.Colors.premiumGold)
                }
                
                if let salaryRange = job.salaryRange {
                    Text(salaryRange.formattedRange)
                        .font(Constants.Fonts.body)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.success)
                }
                
                HStack {
                    Text("\(job.applicantCount) applicants")
                        .font(Constants.Fonts.caption1)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    
                    Spacer()
                    
                    if job.isEasyApply {
                        Text("Easy Apply")
                            .font(Constants.Fonts.caption1)
                            .fontWeight(.medium)
                            .foregroundColor(Constants.Colors.success)
                    }
                }
            }
            .padding(Constants.Spacing.md)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 280)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.card)
                .stroke(Constants.Colors.premiumGold.opacity(0.3), lineWidth: 1)
        )
        .shadow(
            color: Constants.Shadow.card.color,
            radius: Constants.Shadow.card.radius,
            x: Constants.Shadow.card.x,
            y: Constants.Shadow.card.y
        )
    }
}

// MARK: - Job Card Skeleton View
struct JobCardSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack(alignment: .top) {
                RoundedRectangle(cornerRadius: Constants.CornerRadius.small)
                    .fill(Constants.Colors.lightGray)
                    .frame(width: 48, height: 48)
                    .shimmer(isLoading: true)
                
                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    Rectangle()
                        .fill(Constants.Colors.lightGray)
                        .frame(height: 20)
                        .shimmer(isLoading: true)
                    
                    Rectangle()
                        .fill(Constants.Colors.lightGray)
                        .frame(width: 120, height: 16)
                        .shimmer(isLoading: true)
                    
                    Rectangle()
                        .fill(Constants.Colors.lightGray)
                        .frame(width: 100, height: 14)
                        .shimmer(isLoading: true)
                }
                
                Spacer()
                
                Rectangle()
                    .fill(Constants.Colors.lightGray)
                    .frame(width: 24, height: 24)
                    .shimmer(isLoading: true)
            }
            
            HStack {
                ForEach(0..<3, id: \.self) { _ in
                    Rectangle()
                        .fill(Constants.Colors.lightGray)
                        .frame(width: 60, height: 20)
                        .cornerRadius(Constants.CornerRadius.small)
                        .shimmer(isLoading: true)
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
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.vertical, Constants.Spacing.xs)
    }
}

#Preview {
    JobsView()
} 