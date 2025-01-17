import SwiftUI

struct BottomContent: View {
    
    let action: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    action()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24.0, height: 24.0)
                        .contentShape(Rectangle())
                        .foregroundColor(.gray)
                }
                .padding(.top, -12)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    Text("Welcome to your personalized dashboard!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                                
                    // Subheader
                    Text(
                        "Here’s an overview of your recent activity and progress:"
                    )
                    .font(.headline)
                    .foregroundColor(.secondary)
                                
                    // Section 1: Tasks
                    Text("Tasks")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 16)
                                
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📌 Complete the \"User Feedback Analysis\"")
                        Text("📌 Schedule a team meeting for Q1 planning")
                        Text("📌 Review the draft for the new project proposal")
                    }
                    .padding(.leading, 16)
                                
                    // Section 2: Statistics
                    Text("Statistics")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 16)
                                
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🚀 Project completion rate: 76%")
                        Text("📈 Weekly active users: 12,340")
                        Text("⏱ Average response time: 2.3s")
                    }
                    .padding(.leading, 16)
                                
                    // Section 3: Notifications
                    Text("Notifications")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 16)
                                
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🛠 Scheduled maintenance on January 20, 2025.")
                        Text(
                            "🎉 You’ve unlocked a new achievement: \"Top Collaborator.\""
                        )
                        Text("🔔 Your subscription renews in 3 days.")
                    }
                    .padding(.leading, 16)
                                
                    // Footer
                    Spacer().frame(height: 32)
                    Text("Stay productive and have a great day! 😊")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)
                }
                .padding(16)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
