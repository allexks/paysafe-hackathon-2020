//
//  DashboardSection.swift
//  MoneyMate
//
//  Created by Alexander Ignatov on 3.10.20.
//  Copyright © 2020 Luboslav  Ivanov. All rights reserved.
//

import Foundation

enum DashboardSection: Int, CaseIterable {
    case activeIncome
    case ongoingQuests
    case ongoingCourses
    case availableQuests
    case liabilities
    case completedCourses
    case completedQuests
    
    var title: String {
        switch self {
            case .activeIncome: return "Income"
            case .ongoingQuests: return "Ongoing Quests"
            case .availableQuests: return "Available Quests"
            case .liabilities: return "Liabilities"
            case .ongoingCourses: return "Ongoing Courses"
            case .completedCourses: return "Completed Courses"
            case .completedQuests: return "Completed Quests"
        }
    }
    
    private var account: AccountData {
        GameDataStore.shared.account
    }
    
    var itemViewModels: [DashboardItemViewModel] {
        switch self {
            case .activeIncome:
                return account.jobs
                    .map(DashboardItemViewModel.init(from:))
                    + account.items
                    .filter { $0.isAsset }
                    .map(DashboardItemViewModel.init(from:))
            case .ongoingQuests:
                return account.ongoingQuests
                    .map(DashboardItemViewModel.init(from:))
            case .availableQuests:
                return GameDataStore.shared.quests
                    .filter { q in
                        !account.completedQuests.contains(q)
                        && !account.ongoingQuests.contains(q)
                        && Set(q.unlockingRequirementsQuests).isSubset(of: account.completedQuests.map { c in c.name })
                        && Set(q.unlockingRequirementsCourses).isSubset(of: account.completedCourses.map { c in c.name })
                    }.map(DashboardItemViewModel.init(from:))
            case .liabilities:
                return account.items.filter { !$0.isAsset }
                    .map(DashboardItemViewModel.init(from:))
            case .ongoingCourses:
                return account.ongoingCourses.map(DashboardItemViewModel.init(from:))
            case .completedCourses:
                return account.completedCourses.map(DashboardItemViewModel.init(from:))
            case .completedQuests:
                return account.completedQuests.map(DashboardItemViewModel.init(from:))
        }
    }
}

extension DashboardItemViewModel {
    init(from model: JobData) {
        self.title = model.name
        self.description = model.description
        self.descriptions = ["+ $\(model.income.value) / \(model.income.regularity.rawValue)"]
        self.systemImageTitle = "briefcase"
        self.isAsset = true
        self.progress = nil
        self.isQuest = false
    }
    
    init(from model: CourseData) {
        self.title = model.name
        self.description = model.description
        self.systemImageTitle = "book"
        self.isAsset = false
        self.isQuest = false
        
        if GameDataStore.shared.account
            .ongoingCourses.contains(model) {
//            let duration = model.examDate.timeIntervalSince(model.enrollmentDate)
//            let elapsed = GameDataStore.shared.date.timeIntervalSince(model.enrollmentDate)
//            let prog = Float(elapsed / duration)
            self.descriptions = /*prog >= 1.0 ? ["Take exam!"] :*/ []
            self.progress = nil//prog
        } else {
            self.progress = nil
            self.descriptions = []
        }
        
    }
    
    init(from model: ItemData) {
        self.title = model.name
        self.description = model.description
        self.isAsset = model.isAsset
        self.systemImageTitle = "briefcase"
        var desc: [String] = []
        var prog: Float? = nil
        self.isQuest = false
        
        if let loan = model.loan {
            #warning("TODO: calculate progress based on loan start date")
//            let duration = loan.startDate
//                .addingTimeInterval(loan.regularity.timeInterval * Double(loan.paymentsCount))
//                .timeIntervalSince(loan.startDate)
//            let elapsed = GameDataStore.shared.date
//                .timeIntervalSince(loan.startDate)
//            prog = Float(elapsed / duration)
            desc.append("- \(loan.value) / \(loan.regularity.rawValue)")
            desc.append("Total Loan: \(loan.paymentsCount * loan.value)")
        }
        
        if let income = model.income {
            desc.append("+ \(income.value) / \(income.regularity.rawValue)")
        }
        
        self.descriptions = desc
        self.progress = prog
    }
    
    init(from model: QuestData) {
        self.title = model.name
        self.description = ""
        self.systemImageTitle = "safari"
        self.progress = nil
        self.isAsset = false
        self.isQuest = true
        if model.isCompleted {
            self.descriptions = ["Completed!"]
        } else {
            self.descriptions = []
        }
    }
}
