import Foundation
import SwiftUI

// MARK: - Job Model
struct Job: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var company: String
    var companyLogoURL: String?
    var location: String
    var workType: WorkType
    var employmentType: EmploymentType
    var experienceLevel: ExperienceLevel
    var description: String
    var requirements: [String]
    var responsibilities: [String]
    var benefits: [String]
    var skills: [String]
    var salaryRange: SalaryRange?
    var postedDate: Date
    var applicationDeadline: Date?
    var applicantCount: Int
    var isRemote: Bool
    var isUrgent: Bool
    var isEasyApply: Bool
    var companySize: CompanySize
    var industry: String
    var jobPosterUserId: String
    var jobPosterName: String
    var applications: [JobApplication]
    var isActive: Bool
    var views: Int
    var saves: [String] // User IDs who saved this job
    var tags: [String]
    
    init(
        title: String,
        company: String,
        location: String,
        workType: WorkType,
        employmentType: EmploymentType,
        experienceLevel: ExperienceLevel,
        description: String,
        industry: String,
        jobPosterUserId: String,
        jobPosterName: String
    ) {
        self.title = title
        self.company = company
        self.location = location
        self.workType = workType
        self.employmentType = employmentType
        self.experienceLevel = experienceLevel
        self.description = description
        self.requirements = []
        self.responsibilities = []
        self.benefits = []
        self.skills = []
        self.applicantCount = 0
        self.isRemote = workType == .remote
        self.isUrgent = false
        self.isEasyApply = true
        self.companySize = .medium
        self.industry = industry
        self.jobPosterUserId = jobPosterUserId
        self.jobPosterName = jobPosterName
        self.applications = []
        self.isActive = true
        self.views = 0
        self.saves = []
        self.tags = []
        self.postedDate = Date()
    }
}

// MARK: - Job Application Model
struct JobApplication: Identifiable, Codable {
    var id: String = UUID().uuidString
    var jobId: String
    var applicantUserId: String
    var applicantName: String
    var applicantEmail: String
    var applicantProfileImageURL: String?
    var resumeURL: String?
    var coverLetter: String?
    var applicationDate: Date
    var status: ApplicationStatus
    var notes: String?
    
    init(
        jobId: String,
        applicantUserId: String,
        applicantName: String,
        applicantEmail: String
    ) {
        self.jobId = jobId
        self.applicantUserId = applicantUserId
        self.applicantName = applicantName
        self.applicantEmail = applicantEmail
        self.applicationDate = Date()
        self.status = .submitted
    }
}

// MARK: - Supporting Enums
enum WorkType: String, CaseIterable, Codable {
    case remote = "remote"
    case onSite = "on_site"
    case hybrid = "hybrid"
    
    var title: String {
        switch self {
        case .remote:
            return "Remote"
        case .onSite:
            return "On-site"
        case .hybrid:
            return "Hybrid"
        }
    }
    
    var icon: String {
        switch self {
        case .remote:
            return "house.fill"
        case .onSite:
            return "building.2.fill"
        case .hybrid:
            return "arrow.triangle.swap"
        }
    }
}

enum EmploymentType: String, CaseIterable, Codable {
    case fullTime = "full_time"
    case partTime = "part_time"
    case contract = "contract"
    case internship = "internship"
    case freelance = "freelance"
    
    var title: String {
        switch self {
        case .fullTime:
            return "Full-time"
        case .partTime:
            return "Part-time"
        case .contract:
            return "Contract"
        case .internship:
            return "Internship"
        case .freelance:
            return "Freelance"
        }
    }
}

enum ExperienceLevel: String, CaseIterable, Codable {
    case internship = "internship"
    case entryLevel = "entry_level"
    case associate = "associate"
    case midLevel = "mid_level"
    case senior = "senior"
    case director = "director"
    case executive = "executive"
    
    var title: String {
        switch self {
        case .internship:
            return "Internship"
        case .entryLevel:
            return "Entry level"
        case .associate:
            return "Associate"
        case .midLevel:
            return "Mid level"
        case .senior:
            return "Senior level"
        case .director:
            return "Director"
        case .executive:
            return "Executive"
        }
    }
    
    var yearsExperience: String {
        switch self {
        case .internship:
            return "0 years"
        case .entryLevel:
            return "0-1 years"
        case .associate:
            return "1-3 years"
        case .midLevel:
            return "3-5 years"
        case .senior:
            return "5-10 years"
        case .director:
            return "10+ years"
        case .executive:
            return "15+ years"
        }
    }
}

enum ApplicationStatus: String, CaseIterable, Codable {
    case submitted = "submitted"
    case reviewing = "reviewing"
    case shortlisted = "shortlisted"
    case interviewing = "interviewing"
    case offered = "offered"
    case accepted = "accepted"
    case rejected = "rejected"
    case withdrawn = "withdrawn"
    
    var title: String {
        switch self {
        case .submitted:
            return "Submitted"
        case .reviewing:
            return "Under Review"
        case .shortlisted:
            return "Shortlisted"
        case .interviewing:
            return "Interviewing"
        case .offered:
            return "Offer Extended"
        case .accepted:
            return "Accepted"
        case .rejected:
            return "Not Selected"
        case .withdrawn:
            return "Withdrawn"
        }
    }
    
    var color: Color {
        switch self {
        case .submitted, .reviewing:
            return Constants.Colors.warning
        case .shortlisted, .interviewing:
            return Constants.Colors.primaryBlue
        case .offered:
            return Constants.Colors.success
        case .accepted:
            return Constants.Colors.shareGreen
        case .rejected, .withdrawn:
            return Constants.Colors.error
        }
    }
}

enum CompanySize: String, CaseIterable, Codable {
    case startup = "startup"
    case small = "small"
    case medium = "medium"
    case large = "large"
    case enterprise = "enterprise"
    
    var title: String {
        switch self {
        case .startup:
            return "Startup (1-10 employees)"
        case .small:
            return "Small (11-50 employees)"
        case .medium:
            return "Medium (51-200 employees)"
        case .large:
            return "Large (201-1000 employees)"
        case .enterprise:
            return "Enterprise (1000+ employees)"
        }
    }
}

// MARK: - Salary Range Model
struct SalaryRange: Codable {
    var minSalary: Int
    var maxSalary: Int
    var currency: String
    var period: SalaryPeriod
    
    init(minSalary: Int, maxSalary: Int, currency: String = "USD", period: SalaryPeriod = .yearly) {
        self.minSalary = minSalary
        self.maxSalary = maxSalary
        self.currency = currency
        self.period = period
    }
    
    var formattedRange: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 0
        
        let minFormatted = formatter.string(from: NSNumber(value: minSalary)) ?? "$\(minSalary)"
        let maxFormatted = formatter.string(from: NSNumber(value: maxSalary)) ?? "$\(maxSalary)"
        
        return "\(minFormatted) - \(maxFormatted) \(period.suffix)"
    }
}

enum SalaryPeriod: String, CaseIterable, Codable {
    case hourly = "hourly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var suffix: String {
        switch self {
        case .hourly:
            return "per hour"
        case .monthly:
            return "per month"
        case .yearly:
            return "per year"
        }
    }
}

// MARK: - Job Search Filters
struct JobSearchFilters {
    var keywords: String = ""
    var location: String = ""
    var workTypes: Set<WorkType> = []
    var employmentTypes: Set<EmploymentType> = []
    var experienceLevels: Set<ExperienceLevel> = []
    var industries: Set<String> = []
    var salaryRange: SalaryRange?
    var isRemoteOnly: Bool = false
    var isEasyApplyOnly: Bool = false
    var postedWithin: DateRange = .anyTime
    var companySizes: Set<CompanySize> = []
}

enum DateRange: String, CaseIterable {
    case anyTime = "any_time"
    case pastDay = "past_day"
    case pastWeek = "past_week"
    case pastMonth = "past_month"
    
    var title: String {
        switch self {
        case .anyTime:
            return "Any time"
        case .pastDay:
            return "Past 24 hours"
        case .pastWeek:
            return "Past week"
        case .pastMonth:
            return "Past month"
        }
    }
    
    var dateFilter: Date? {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .anyTime:
            return nil
        case .pastDay:
            return calendar.date(byAdding: .day, value: -1, to: now)
        case .pastWeek:
            return calendar.date(byAdding: .weekOfYear, value: -1, to: now)
        case .pastMonth:
            return calendar.date(byAdding: .month, value: -1, to: now)
        }
    }
} 