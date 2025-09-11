//
//  MockTypes.swift
//  JustDad - Mock data types
//
//  Mock data type definitions for app development and testing
//

import Foundation
import SwiftUI

// MARK: - Mock Visit
struct MockVisit: Identifiable {
    let id = UUID()
    var date: Date
    var title: String
    var notes: String?
    
    static let sampleVisits: [MockVisit] = [
        MockVisit(
            date: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
            title: "Doctor checkup",
            notes: "Regular pediatric visit for growth monitoring"
        ),
        MockVisit(
            date: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            title: "Dental appointment",
            notes: "First dental visit - teeth cleaning"
        ),
        MockVisit(
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            title: "Vaccination",
            notes: "Second dose of MMR vaccine"
        )
    ]
}

// MARK: - Mock Expense
struct MockExpense: Identifiable {
    let id = UUID()
    var type: String
    var amount: Double
    var date: Date
    var receiptName: String?
    
    // MARK: - Professional UI Properties
    var title: String {
        switch type {
        case "Healthcare": return "Medical Expenses"
        case "Education": return "Educational Costs"
        case "Food": return "Meal & Groceries"
        case "Transportation": return "Travel & Transport"
        case "Utilities": return "Bills & Utilities"
        case "Entertainment": return "Entertainment"
        case "Shopping": return "Shopping"
        default: return type
        }
    }
    
    var category: String {
        switch type {
        case "Healthcare": return "Medical"
        case "Education": return "Education"
        case "Food": return "Food & Dining"
        case "Transportation": return "Transportation"
        case "Utilities": return "Bills"
        case "Entertainment": return "Entertainment"
        case "Shopping": return "Shopping"
        default: return "Other"
        }
    }
    
    var icon: String {
        switch type {
        case "Healthcare": return "cross.case.fill"
        case "Education": return "graduationcap.fill"
        case "Food": return "fork.knife"
        case "Transportation": return "car.fill"
        case "Utilities": return "bolt.fill"
        case "Entertainment": return "gamecontroller.fill"
        case "Shopping": return "bag.fill"
        default: return "dollarsign.circle.fill"
        }
    }
    
    var color: Color {
        switch type {
        case "Healthcare": return .red
        case "Education": return .blue
        case "Food": return .orange
        case "Transportation": return .green
        case "Utilities": return .yellow
        case "Entertainment": return .purple
        case "Shopping": return .pink
        default: return .gray
        }
    }
    
    static let sampleExpenses: [MockExpense] = [
        MockExpense(
            type: "Healthcare",
            amount: 125.50,
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            receiptName: "receipt_doctor_visit.pdf"
        ),
        MockExpense(
            type: "Education",
            amount: 89.99,
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            receiptName: "receipt_books.pdf"
        ),
        MockExpense(
            type: "Food",
            amount: 42.30,
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            receiptName: nil
        )
    ]
}

// MARK: - Mock Journal Entry
struct MockJournalEntry: Identifiable {
    let id = UUID()
    
    enum Kind {
        case text
        case audio
        case photo
    }
    
    enum Mood: String, CaseIterable {
        case happy = "😊"
        case sad = "😢"  
        case neutral = "😐"
        case excited = "🎉"
        case stressed = "😰"
        case grateful = "🙏"
    }
    
    var kind: Kind
    var title: String
    var content: String
    var date: Date
    var tags: [String]
    var mood: Mood
    
    static let sampleEntries: [MockJournalEntry] = [
        MockJournalEntry(
            kind: .text,
            title: "First steps!",
            content: "Today was incredible! Emma took her first steps without holding onto anything. She was so proud of herself and kept giggling every time she managed a few steps.",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            tags: ["milestone", "walking", "proud"],
            mood: .excited
        ),
        MockJournalEntry(
            kind: .photo,
            title: "Bedtime story",
            content: "Reading 'Goodnight Moon' together. Her favorite part is when the bunny says goodnight to everything.",
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            tags: ["bedtime", "reading", "routine"],
            mood: .grateful
        ),
        MockJournalEntry(
            kind: .audio,
            title: "First words recording",
            content: "Recorded her saying 'Dada' clearly for the first time. Such a special moment.",
            date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            tags: ["milestone", "speech", "first words"],
            mood: .happy
        ),
        MockJournalEntry(
            kind: .text,
            title: "Playground adventure",
            content: "Spent the afternoon at the new playground. She loved the swings and wasn't afraid of the slide at all. Made friends with another toddler.",
            date: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
            tags: ["playground", "social", "outdoor"],
            mood: .happy
        )
    ]
}

// MARK: - Mock Community Post
struct MockCommunityPost: Identifiable {
    let id = UUID()
    var nickname: String
    var category: String
    var text: String
    var date: Date
    var replies: [String]
    
    // MARK: - Professional UI Properties
    var author: String {
        return nickname
    }
    
    var isLiked: Bool {
        return false // Default value, can be overridden
    }
    
    var likesCount: Int {
        return Int.random(in: 0...25) // Random likes for variety
    }
    
    var commentsCount: Int {
        return replies.count
    }
    
    static let samplePosts: [MockCommunityPost] = [
        MockCommunityPost(
            nickname: "DadOfTwo",
            category: "Sleep Tips",
            text: "Anyone have advice for sleep regression at 18 months? My little one was sleeping through the night and now wakes up multiple times.",
            date: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            replies: ["Have you tried a later bedtime?", "Going through the same thing!", "This too shall pass - hang in there!"]
        ),
        MockCommunityPost(
            nickname: "FirstTimeFather",
            category: "Feeding",
            text: "Tips for introducing solid foods? My 6-month-old seems interested but I'm nervous about choking hazards.",
            date: Calendar.current.date(byAdding: .hour, value: -6, to: Date()) ?? Date(),
            replies: ["Start with soft finger foods", "Baby-led weaning worked great for us"]
        ),
        MockCommunityPost(
            nickname: "GirlDadLife",
            category: "Activities",
            text: "Indoor activity ideas for rainy days? Running out of things to do with my 2-year-old.",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            replies: ["Sensory bins are amazing!", "We love dance parties", "Painting with water is mess-free"]
        ),
        MockCommunityPost(
            nickname: "WorkingDad23",
            category: "Work-Life Balance",
            text: "How do you manage work stress when you just want to be present for your kids?",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            replies: ["Meditation helps me", "Set boundaries with work", "Remember quality over quantity"]
        ),
        MockCommunityPost(
            nickname: "SingleDadStrong",
            category: "Support",
            text: "To all the dads out there - you're doing great! Some days are harder than others but we've got this.",
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            replies: ["Thank you for this", "Needed to hear this today", "Dad solidarity! 💪"]
        )
    ]
}
