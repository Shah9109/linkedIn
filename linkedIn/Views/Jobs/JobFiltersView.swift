import SwiftUI

struct JobFiltersView: View {
    @Binding var filters: JobSearchFilters
    let onApply: (JobSearchFilters) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var tempFilters: JobSearchFilters
    
    init(filters: Binding<JobSearchFilters>, onApply: @escaping (JobSearchFilters) -> Void) {
        self._filters = filters
        self.onApply = onApply
        var initialFilters = filters.wrappedValue
        if initialFilters.salaryRange == nil {
            initialFilters.salaryRange = SalaryRange(minSalary: 50000, maxSalary: 150000)
        }
        self._tempFilters = State(initialValue: initialFilters)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.Spacing.lg) {
                    // Location Filter
                    locationSection
                    
                    // Work Type Filter
                    workTypeSection
                    
                    // Employment Type Filter
                    employmentTypeSection
                    
                    // Experience Level Filter
                    experienceLevelSection
                    
                    // Salary Range Filter
                    salaryRangeSection
                    
                    // Date Posted Filter
                    datePostedSection
                    
                    // Additional Filters
                    additionalFiltersSection
                }
                .padding(Constants.Spacing.md)
            }
            .background(Constants.Colors.professionalGray)
            .navigationTitle("Job Filters")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Clear All") {
                    clearAllFilters()
                },
                trailing: HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                    Button("Apply") {
                        applyFilters()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, Constants.Spacing.md)
                    .padding(.vertical, Constants.Spacing.sm)
                    .background(Constants.Colors.primaryBlue)
                    .cornerRadius(Constants.CornerRadius.pill)
                }
            )
        }
    }
    
    // MARK: - Location Section
    private var locationSection: some View {
        FilterSectionView(title: "Location", icon: "location.fill") {
            VStack(spacing: Constants.Spacing.md) {
                TextField("Enter city, state, or country", text: $tempFilters.location)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Popular locations
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Constants.Spacing.sm) {
                    ForEach(popularLocations, id: \.self) { location in
                        Button(action: { tempFilters.location = location }) {
                            Text(location)
                                .font(Constants.Fonts.body)
                                .foregroundColor(tempFilters.location == location ? .white : Constants.Colors.primaryBlue)
                                .padding(.horizontal, Constants.Spacing.md)
                                .padding(.vertical, Constants.Spacing.sm)
                                .background(tempFilters.location == location ? Constants.Colors.primaryBlue : Constants.Colors.lightBlue.opacity(0.2))
                                .cornerRadius(Constants.CornerRadius.pill)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Work Type Section
    private var workTypeSection: some View {
        FilterSectionView(title: "Work Type", icon: "briefcase.fill") {
            VStack(spacing: Constants.Spacing.sm) {
                ForEach(WorkType.allCases, id: \.self) { workType in
                    FilterCheckboxRow(
                        title: workType.title,
                        icon: workType.icon,
                        isSelected: tempFilters.workTypes.contains(workType)
                    ) {
                        toggleWorkType(workType)
                    }
                }
            }
        }
    }
    
    // MARK: - Employment Type Section
    private var employmentTypeSection: some View {
        FilterSectionView(title: "Employment Type", icon: "clock.fill") {
            VStack(spacing: Constants.Spacing.sm) {
                ForEach(EmploymentType.allCases, id: \.self) { employmentType in
                    FilterCheckboxRow(
                        title: employmentType.title,
                        icon: "briefcase.fill",
                        isSelected: tempFilters.employmentTypes.contains(employmentType)
                    ) {
                        toggleEmploymentType(employmentType)
                    }
                }
            }
        }
    }
    
    // MARK: - Experience Level Section
    private var experienceLevelSection: some View {
        FilterSectionView(title: "Experience Level", icon: "person.fill") {
            VStack(spacing: Constants.Spacing.sm) {
                ForEach(ExperienceLevel.allCases, id: \.self) { level in
                    FilterCheckboxRow(
                        title: level.title,
                        subtitle: level.yearsExperience,
                        icon: "person.badge.clock",
                        isSelected: tempFilters.experienceLevels.contains(level)
                    ) {
                        toggleExperienceLevel(level)
                    }
                }
            }
        }
    }
    
    // MARK: - Salary Range Section
    private var salaryRangeSection: some View {
        FilterSectionView(title: "Salary Range", icon: "dollarsign.circle.fill") {
            VStack(spacing: Constants.Spacing.md) {
                
                VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                    HStack {
                        Text("Minimum Salary")
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.label)
                        Spacer()
                        Text("$\(tempFilters.salaryRange?.minSalary ?? 50000, specifier: "%.0f")")
                            .font(Constants.Fonts.body)
                            .fontWeight(.medium)
                            .foregroundColor(Constants.Colors.primaryBlue)
                    }
                    
                    Slider(
                        value: Binding(
                            get: { Double(tempFilters.salaryRange?.minSalary ?? 50000) },
                            set: { newValue in
                                if tempFilters.salaryRange == nil {
                                    tempFilters.salaryRange = SalaryRange(minSalary: Int(newValue), maxSalary: 150000)
                                } else {
                                    tempFilters.salaryRange!.minSalary = Int(newValue)
                                }
                            }
                        ),
                        in: 30000...300000,
                        step: 5000
                    )
                    .accentColor(Constants.Colors.primaryBlue)
                }
                
                VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                    HStack {
                        Text("Maximum Salary")
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.label)
                        Spacer()
                        Text("$\(tempFilters.salaryRange?.maxSalary ?? 150000, specifier: "%.0f")")
                            .font(Constants.Fonts.body)
                            .fontWeight(.medium)
                            .foregroundColor(Constants.Colors.primaryBlue)
                    }
                    
                    Slider(
                        value: Binding(
                            get: { Double(tempFilters.salaryRange?.maxSalary ?? 150000) },
                            set: { newValue in
                                if tempFilters.salaryRange == nil {
                                    tempFilters.salaryRange = SalaryRange(minSalary: 50000, maxSalary: Int(newValue))
                                } else {
                                    tempFilters.salaryRange!.maxSalary = Int(newValue)
                                }
                            }
                        ),
                        in: 50000...500000,
                        step: 5000
                    )
                    .accentColor(Constants.Colors.primaryBlue)
                }
            }
        }
    }
    
    // MARK: - Date Posted Section
    private var datePostedSection: some View {
        FilterSectionView(title: "Date Posted", icon: "calendar.circle.fill") {
            VStack(spacing: Constants.Spacing.sm) {
                ForEach(DateRange.allCases, id: \.self) { dateRange in
                    FilterRadioRow(
                        title: dateRange.title,
                        isSelected: tempFilters.postedWithin == dateRange
                    ) {
                        tempFilters.postedWithin = dateRange
                    }
                }
            }
        }
    }
    
    // MARK: - Additional Filters Section
    private var additionalFiltersSection: some View {
        FilterSectionView(title: "Additional Filters", icon: "slider.horizontal.3") {
            VStack(spacing: Constants.Spacing.md) {
                FilterToggleRow(
                    title: "Remote Only",
                    subtitle: "Show only remote positions",
                    icon: "house.fill",
                    isOn: $tempFilters.isRemoteOnly
                )
                
                FilterToggleRow(
                    title: "Easy Apply Only",
                    subtitle: "Show jobs with easy apply option",
                    icon: "checkmark.circle.fill",
                    isOn: $tempFilters.isEasyApplyOnly
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    private func toggleWorkType(_ workType: WorkType) {
        if tempFilters.workTypes.contains(workType) {
            tempFilters.workTypes.remove(workType)
        } else {
            tempFilters.workTypes.insert(workType)
        }
    }
    
    private func toggleEmploymentType(_ employmentType: EmploymentType) {
        if tempFilters.employmentTypes.contains(employmentType) {
            tempFilters.employmentTypes.remove(employmentType)
        } else {
            tempFilters.employmentTypes.insert(employmentType)
        }
    }
    
    private func toggleExperienceLevel(_ level: ExperienceLevel) {
        if tempFilters.experienceLevels.contains(level) {
            tempFilters.experienceLevels.remove(level)
        } else {
            tempFilters.experienceLevels.insert(level)
        }
    }
    
    private func clearAllFilters() {
        tempFilters = JobSearchFilters()
    }
    
    private func applyFilters() {
        filters = tempFilters
        onApply(tempFilters)
        presentationMode.wrappedValue.dismiss()
    }
    
    private var popularLocations: [String] {
        return [
            "San Francisco, CA",
            "New York, NY",
            "Seattle, WA",
            "Austin, TX",
            "Boston, MA",
            "Los Angeles, CA",
            "Chicago, IL",
            "Remote"
        ]
    }
}

// MARK: - Filter Section View
struct FilterSectionView<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Constants.Colors.primaryBlue)
                
                Text(title)
                    .font(Constants.Fonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Spacer()
            }
            
            content
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

// MARK: - Filter Checkbox Row
struct FilterCheckboxRow: View {
    let title: String
    let subtitle: String?
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void
    
    init(title: String, subtitle: String? = nil, icon: String, isSelected: Bool, onTap: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(Constants.Colors.primaryBlue)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    Text(title)
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.label)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(Constants.Fonts.caption1)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundColor(isSelected ? Constants.Colors.primaryBlue : Constants.Colors.border)
            }
            .padding(.vertical, Constants.Spacing.sm)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Filter Radio Row
struct FilterRadioRow: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.label)
                
                Spacer()
                
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? Constants.Colors.primaryBlue : Constants.Colors.border)
            }
            .padding(.vertical, Constants.Spacing.sm)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Filter Toggle Row
struct FilterToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(Constants.Colors.primaryBlue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                Text(title)
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.label)
                
                Text(subtitle)
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.secondaryLabel)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Constants.Colors.primaryBlue))
        }
        .padding(.vertical, Constants.Spacing.sm)
    }
}

#Preview {
    JobFiltersView(filters: .constant(JobSearchFilters())) { _ in }
} 