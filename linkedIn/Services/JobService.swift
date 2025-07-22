import Foundation
import Combine

class JobService: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var featuredJobs: [Job] = []
    @Published var myApplications: [JobApplication] = []
    @Published var savedJobs: [Job] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseManager = FirebaseManager.shared
    private var jobCache: [String: Job] = [:]
    private var currentPage = 0
    private let pageSize = 20
    private var hasMoreJobs = true
    private var currentFilters = JobSearchFilters()
    
    // Analytics
    @Published var jobAnalytics = JobAnalytics()
    
    init() {
        generateDemoJobs()
    }
    
    // MARK: - Job Search & Discovery
    func searchJobs(filters: JobSearchFilters = JobSearchFilters()) {
        isLoading = true
        errorMessage = nil
        currentFilters = filters
        currentPage = 0
        hasMoreJobs = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            let filteredJobs = self.applyFilters(to: self.getAllJobs(), filters: filters)
            self.jobs = Array(filteredJobs.prefix(self.pageSize))
            self.currentPage = 1
            self.hasMoreJobs = filteredJobs.count > self.pageSize
            
            self.updateAnalytics()
            self.isLoading = false
        }
    }
    
    func loadMoreJobs() {
        guard !isLoading && hasMoreJobs else { return }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            
            let allFilteredJobs = self.applyFilters(to: self.getAllJobs(), filters: self.currentFilters)
            let startIndex = self.currentPage * self.pageSize
            let endIndex = min(startIndex + self.pageSize, allFilteredJobs.count)
            
            if startIndex < allFilteredJobs.count {
                let newJobs = Array(allFilteredJobs[startIndex..<endIndex])
                self.jobs.append(contentsOf: newJobs)
                self.currentPage += 1
                self.hasMoreJobs = endIndex < allFilteredJobs.count
            } else {
                self.hasMoreJobs = false
            }
            
            self.isLoading = false
        }
    }
    
    func getFeaturedJobs() {
        let allJobs = getAllJobs()
        featuredJobs = Array(allJobs.filter { $0.isUrgent || $0.applicantCount > 50 }.shuffled().prefix(5))
    }
    
    func getRecommendedJobs(for userId: String) -> [Job] {
        guard let user = firebaseManager.currentUser else { return [] }
        
        let userSkills = user.skills
        let userIndustries = user.experience.compactMap { $0.company }
        
        return getAllJobs().filter { job in
            // Match by skills
            let skillMatch = !job.skills.isEmpty && job.skills.contains { skill in
                userSkills.contains { userSkill in
                    userSkill.localizedCaseInsensitiveContains(skill) || skill.localizedCaseInsensitiveContains(userSkill)
                }
            }
            
            // Match by industry experience
            let industryMatch = userIndustries.contains { company in
                job.company.localizedCaseInsensitiveContains(company) || job.industry.localizedCaseInsensitiveContains(company)
            }
            
            return skillMatch || industryMatch
        }.sorted { $0.postedDate > $1.postedDate }
    }
    
    // MARK: - Job Applications
    func applyToJob(_ job: Job, coverLetter: String? = nil, resumeURL: String? = nil) {
        guard let currentUser = firebaseManager.currentUser else { return }
        
        let application = JobApplication(
            jobId: job.id,
            applicantUserId: currentUser.id,
            applicantName: currentUser.fullName,
            applicantEmail: currentUser.email
        )
        
        var updatedApplication = application
        updatedApplication.coverLetter = coverLetter
        updatedApplication.resumeURL = resumeURL
        updatedApplication.applicantProfileImageURL = currentUser.profileImageURL
        
        // Update job with new application
        if let jobIndex = jobs.firstIndex(where: { $0.id == job.id }) {
            jobs[jobIndex].applications.append(updatedApplication)
            jobs[jobIndex].applicantCount += 1
        }
        
        // Add to user's applications
        myApplications.append(updatedApplication)
        
        // Analytics tracking
        trackJobApplication(job)
        
        print("✅ Applied to job: \(job.title) at \(job.company)")
    }
    
    func withdrawApplication(for jobId: String) {
        guard let currentUserId = firebaseManager.currentUser?.id else { return }
        
        // Update job applications
        if let jobIndex = jobs.firstIndex(where: { $0.id == jobId }) {
            jobs[jobIndex].applications.removeAll { $0.applicantUserId == currentUserId }
            jobs[jobIndex].applicantCount = max(0, jobs[jobIndex].applicantCount - 1)
        }
        
        // Update user applications
        if let appIndex = myApplications.firstIndex(where: { $0.jobId == jobId && $0.applicantUserId == currentUserId }) {
            myApplications[appIndex].status = .withdrawn
        }
    }
    
    func getMyApplications() -> [JobApplication] {
        guard let currentUserId = firebaseManager.currentUser?.id else { return [] }
        return myApplications.filter { $0.applicantUserId == currentUserId }
    }
    
    // MARK: - Job Management (For Job Posters)
    func postJob(_ job: Job) {
        var newJob = job
        newJob.postedDate = Date()
        newJob.isActive = true
        
        // Add to jobs list
        jobs.insert(newJob, at: 0)
        cacheJob(newJob)
        
        print("📝 Posted new job: \(job.title) at \(job.company)")
    }
    
    func updateJob(_ job: Job) {
        guard let index = jobs.firstIndex(where: { $0.id == job.id }) else { return }
        jobs[index] = job
        cacheJob(job)
    }
    
    func deactivateJob(_ jobId: String) {
        guard let index = jobs.firstIndex(where: { $0.id == jobId }) else { return }
        jobs[index].isActive = false
    }
    
    // MARK: - Saved Jobs
    func saveJob(_ job: Job) {
        guard let currentUserId = firebaseManager.currentUser?.id else { return }
        
        if !savedJobs.contains(where: { $0.id == job.id }) {
            savedJobs.append(job)
            
            // Update job's saves list
            if let jobIndex = jobs.firstIndex(where: { $0.id == job.id }) {
                jobs[jobIndex].saves.append(currentUserId)
            }
            
            print("💾 Saved job: \(job.title)")
        }
    }
    
    func unsaveJob(_ job: Job) {
        guard let currentUserId = firebaseManager.currentUser?.id else { return }
        
        savedJobs.removeAll { $0.id == job.id }
        
        // Update job's saves list
        if let jobIndex = jobs.firstIndex(where: { $0.id == job.id }) {
            jobs[jobIndex].saves.removeAll { $0 == currentUserId }
        }
    }
    
    func isJobSaved(_ jobId: String) -> Bool {
        return savedJobs.contains { $0.id == jobId }
    }
    
    // MARK: - Job Analytics
    func getJobAnalytics(for jobId: String) -> JobDetailAnalytics? {
        guard let job = getJob(by: jobId) else { return nil }
        
        return JobDetailAnalytics(
            jobId: jobId,
            views: job.views,
            applications: job.applicantCount,
            saves: job.saves.count,
            clickThroughRate: job.views > 0 ? Double(job.applicantCount) / Double(job.views) * 100 : 0,
            averageTimeToApply: generateRandomTimeToApply(),
            topApplicationSources: ["ProNet Mobile", "ProNet Web", "Direct Apply", "Referral"],
            demographicBreakdown: generateDemographicBreakdown()
        )
    }
    
    // MARK: - Industry Insights
    func getTrendingJobs() -> [String] {
        let jobTitles = getAllJobs().map { $0.title }
        var titleCounts: [String: Int] = [:]
        
        jobTitles.forEach { title in
            let baseTitle = extractBaseJobTitle(title)
            titleCounts[baseTitle, default: 0] += 1
        }
        
        return titleCounts
            .sorted { $0.value > $1.value }
            .prefix(10)
            .map { $0.key }
    }
    
    func getSalaryInsights(for jobTitle: String) -> SalaryInsights {
        let similarJobs = getAllJobs().filter { job in
            job.title.localizedCaseInsensitiveContains(jobTitle) ||
            jobTitle.localizedCaseInsensitiveContains(job.title)
        }
        
        let salaries = similarJobs.compactMap { $0.salaryRange }
        guard !salaries.isEmpty else {
            return SalaryInsights(averageMin: 0, averageMax: 0, jobCount: 0, currency: "USD")
        }
        
        let avgMin = salaries.map { $0.minSalary }.reduce(0, +) / salaries.count
        let avgMax = salaries.map { $0.maxSalary }.reduce(0, +) / salaries.count
        
        return SalaryInsights(
            averageMin: avgMin,
            averageMax: avgMax,
            jobCount: similarJobs.count,
            currency: salaries.first?.currency ?? "USD"
        )
    }
    
    // MARK: - Helper Methods
    private func getAllJobs() -> [Job] {
        return generateAllDemoJobs()
    }
    
    private func applyFilters(to jobs: [Job], filters: JobSearchFilters) -> [Job] {
        return jobs.filter { job in
            // Keywords filter
            let keywordMatch = filters.keywords.isEmpty ||
                job.title.localizedCaseInsensitiveContains(filters.keywords) ||
                job.company.localizedCaseInsensitiveContains(filters.keywords) ||
                job.skills.contains { $0.localizedCaseInsensitiveContains(filters.keywords) }
            
            // Location filter
            let locationMatch = filters.location.isEmpty ||
                job.location.localizedCaseInsensitiveContains(filters.location)
            
            // Work type filter
            let workTypeMatch = filters.workTypes.isEmpty || filters.workTypes.contains(job.workType)
            
            // Employment type filter
            let employmentMatch = filters.employmentTypes.isEmpty || filters.employmentTypes.contains(job.employmentType)
            
            // Experience level filter
            let experienceMatch = filters.experienceLevels.isEmpty || filters.experienceLevels.contains(job.experienceLevel)
            
            // Remote only filter
            let remoteMatch = !filters.isRemoteOnly || job.isRemote
            
            // Easy apply filter
            let easyApplyMatch = !filters.isEasyApplyOnly || job.isEasyApply
            
            // Date filter
            let dateMatch: Bool
            if let dateFilter = filters.postedWithin.dateFilter {
                dateMatch = job.postedDate >= dateFilter
            } else {
                dateMatch = true
            }
            
            return keywordMatch && locationMatch && workTypeMatch && employmentMatch && 
                   experienceMatch && remoteMatch && easyApplyMatch && dateMatch
        }
    }
    
    private func cacheJob(_ job: Job) {
        jobCache[job.id] = job
    }
    
    private func getJob(by id: String) -> Job? {
        return jobCache[id] ?? jobs.first { $0.id == id }
    }
    
    private func extractBaseJobTitle(_ title: String) -> String {
        // Simplify job titles for trending analysis
        let commonTitles = ["Software Engineer", "Product Manager", "Data Scientist", "Designer", "Marketing Manager", "Sales Manager"]
        
        for commonTitle in commonTitles {
            if title.localizedCaseInsensitiveContains(commonTitle) {
                return commonTitle
            }
        }
        
        return title
    }
    
    private func generateRandomTimeToApply() -> Double {
        return Double.random(in: 2.5...8.0) // days
    }
    
    private func generateDemographicBreakdown() -> [String: Int] {
        return [
            "0-2 years exp": Int.random(in: 20...40),
            "3-5 years exp": Int.random(in: 25...45),
            "5+ years exp": Int.random(in: 15...35)
        ]
    }
    
    // MARK: - Analytics Tracking
    private func updateAnalytics() {
        let totalJobs = jobs.count
        let totalApplications = jobs.reduce(0) { $0 + $1.applicantCount }
        let averageSalary = calculateAverageSalary()
        
        jobAnalytics = JobAnalytics(
            totalJobs: totalJobs,
            totalApplications: totalApplications,
            averageSalary: averageSalary,
            topIndustries: getTopIndustries(),
            topLocations: getTopLocations()
        )
    }
    
    private func trackJobApplication(_ job: Job) {
        print("📊 Analytics: Applied to \(job.title) at \(job.company)")
    }
    
    private func calculateAverageSalary() -> Int {
        let jobsWithSalary = jobs.compactMap { $0.salaryRange }
        guard !jobsWithSalary.isEmpty else { return 0 }
        
        let averages = jobsWithSalary.map { ($0.minSalary + $0.maxSalary) / 2 }
        return averages.reduce(0, +) / averages.count
    }
    
    private func getTopIndustries() -> [String] {
        let industries = jobs.map { $0.industry }
        var industryCounts: [String: Int] = [:]
        
        industries.forEach { industry in
            industryCounts[industry, default: 0] += 1
        }
        
        return industryCounts
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }
    }
    
    private func getTopLocations() -> [String] {
        let locations = jobs.map { $0.location }
        var locationCounts: [String: Int] = [:]
        
        locations.forEach { location in
            locationCounts[location, default: 0] += 1
        }
        
        return locationCounts
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }
    }
    
    // MARK: - Demo Data Generation
    private func generateDemoJobs() {
        let demoJobs = generateProfessionalJobs(count: 10)
        self.jobs = demoJobs
        self.featuredJobs = Array(demoJobs.shuffled().prefix(3))
        updateAnalytics()
    }
    
    private func generateAllDemoJobs() -> [Job] {
        return generateProfessionalJobs(count: 100)
    }
    
    private func generateProfessionalJobs(count: Int) -> [Job] {
        let jobTitles = [
            "Senior Software Engineer", "Product Manager", "Data Scientist", "UX Designer",
            "Marketing Manager", "Sales Director", "DevOps Engineer", "Business Analyst",
            "Frontend Developer", "Backend Engineer", "Mobile Developer", "QA Engineer",
            "Technical Lead", "Engineering Manager", "Growth Manager", "Content Manager"
        ]
        
        let companies = Constants.SampleData.companies
        let locations = [
            "San Francisco, CA", "New York, NY", "Seattle, WA", "Austin, TX", "Boston, MA",
            "Los Angeles, CA", "Chicago, IL", "Denver, CO", "Remote", "London, UK", "Toronto, ON"
        ]
        
        let industries = Constants.SampleData.industries
        let skills = Constants.SampleData.skills
        
        return (0..<count).map { index in
            let title = jobTitles[index % jobTitles.count]
            let company = companies[index % companies.count]
            let location = locations[index % locations.count]
            let industry = industries[index % industries.count]
            
            var job = Job(
                title: title,
                company: company,
                location: location,
                workType: location == "Remote" ? .remote : WorkType.allCases.randomElement()!,
                employmentType: EmploymentType.allCases.randomElement()!,
                experienceLevel: ExperienceLevel.allCases.randomElement()!,
                description: generateJobDescription(for: title),
                industry: industry,
                jobPosterUserId: UUID().uuidString,
                jobPosterName: "HR Team"
            )
            
            // Add professional details
            job.companyLogoURL = Constants.Images.companyLogo1
            job.requirements = generateJobRequirements(for: title)
            job.responsibilities = generateJobResponsibilities(for: title)
            job.benefits = generateJobBenefits()
            job.skills = Array(skills.shuffled().prefix(Int.random(in: 3...8)))
            job.salaryRange = generateSalaryRange(for: job.experienceLevel, title: title)
            job.applicantCount = Int.random(in: 5...150)
            job.views = Int.random(in: job.applicantCount * 3...job.applicantCount * 10)
            job.isUrgent = Bool.random() && Int.random(in: 0...10) < 2 // 20% chance
            job.companySize = CompanySize.allCases.randomElement()!
            job.postedDate = Date().addingTimeInterval(-TimeInterval.random(in: 0...(30*24*3600))) // Within last 30 days
            
            return job
        }
    }
    
    private func generateJobDescription(for title: String) -> String {
        let descriptions = [
            "Join our dynamic team and make a significant impact on our products used by millions of users worldwide. We're looking for passionate individuals who thrive in collaborative environments.",
            "We are seeking a talented professional to help drive innovation and growth at our fast-paced company. This role offers excellent opportunities for career development and learning.",
            "Be part of a mission-driven organization that values creativity, innovation, and work-life balance. Help us build the future of technology while growing your career.",
            "Exciting opportunity to work with cutting-edge technology and a world-class team. We offer competitive compensation, comprehensive benefits, and a culture of continuous learning."
        ]
        return descriptions.randomElement() ?? descriptions[0]
    }
    
    private func generateJobRequirements(for title: String) -> [String] {
        let commonRequirements = [
            "Bachelor's degree in relevant field or equivalent experience",
            "Strong problem-solving and analytical skills",
            "Excellent communication and collaboration abilities",
            "Experience with agile development methodologies",
            "Passion for learning and staying current with industry trends"
        ]
        
        let techRequirements = [
            "3+ years of experience in software development",
            "Proficiency in modern programming languages",
            "Experience with cloud platforms (AWS, Azure, GCP)",
            "Knowledge of database systems and SQL"
        ]
        
        if title.contains("Engineer") || title.contains("Developer") {
            return commonRequirements + techRequirements
        }
        
        return commonRequirements + ["Domain expertise in relevant area", "Experience with project management tools"]
    }
    
    private func generateJobResponsibilities(for title: String) -> [String] {
        return [
            "Collaborate with cross-functional teams to deliver high-quality solutions",
            "Participate in planning and design discussions",
            "Contribute to code reviews and technical documentation",
            "Mentor junior team members and share knowledge",
            "Stay current with industry best practices and emerging technologies"
        ]
    }
    
    private func generateJobBenefits() -> [String] {
        return [
            "Competitive salary and equity package",
            "Comprehensive health, dental, and vision insurance",
            "401(k) with company matching",
            "Flexible PTO and work-from-home options",
            "Professional development budget",
            "Catered meals and snacks",
            "Wellness programs and gym membership"
        ]
    }
    
    private func generateSalaryRange(for level: ExperienceLevel, title: String) -> SalaryRange {
        let baseSalary: Int
        
        switch level {
        case .internship:
            baseSalary = 50000
        case .entryLevel:
            baseSalary = 70000
        case .associate:
            baseSalary = 90000
        case .midLevel:
            baseSalary = 120000
        case .senior:
            baseSalary = 150000
        case .director:
            baseSalary = 200000
        case .executive:
            baseSalary = 300000
        }
        
        // Adjust for job title
        let titleMultiplier: Double
        if title.contains("Engineer") || title.contains("Developer") {
            titleMultiplier = 1.1
        } else if title.contains("Manager") || title.contains("Director") {
            titleMultiplier = 1.2
        } else if title.contains("Scientist") {
            titleMultiplier = 1.15
        } else {
            titleMultiplier = 1.0
        }
        
        let adjustedBase = Int(Double(baseSalary) * titleMultiplier)
        let minSalary = adjustedBase - 10000
        let maxSalary = adjustedBase + 20000
        
        return SalaryRange(minSalary: minSalary, maxSalary: maxSalary)
    }
}

// MARK: - Supporting Models
struct JobAnalytics {
    let totalJobs: Int
    let totalApplications: Int
    let averageSalary: Int
    let topIndustries: [String]
    let topLocations: [String]
    
    init() {
        self.totalJobs = 0
        self.totalApplications = 0
        self.averageSalary = 0
        self.topIndustries = []
        self.topLocations = []
    }
    
    init(totalJobs: Int, totalApplications: Int, averageSalary: Int, topIndustries: [String], topLocations: [String]) {
        self.totalJobs = totalJobs
        self.totalApplications = totalApplications
        self.averageSalary = averageSalary
        self.topIndustries = topIndustries
        self.topLocations = topLocations
    }
}

struct JobDetailAnalytics {
    let jobId: String
    let views: Int
    let applications: Int
    let saves: Int
    let clickThroughRate: Double
    let averageTimeToApply: Double
    let topApplicationSources: [String]
    let demographicBreakdown: [String: Int]
}

struct SalaryInsights {
    let averageMin: Int
    let averageMax: Int
    let jobCount: Int
    let currency: String
    
    var formattedRange: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 0
        
        let minFormatted = formatter.string(from: NSNumber(value: averageMin)) ?? "$\(averageMin)"
        let maxFormatted = formatter.string(from: NSNumber(value: averageMax)) ?? "$\(averageMax)"
        
        return "\(minFormatted) - \(maxFormatted)"
    }
} 