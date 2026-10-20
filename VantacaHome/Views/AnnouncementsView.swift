import SwiftUI

struct AnnouncementsView: View {
    @EnvironmentObject var session: AppSession
    @State private var category: AnnouncementCategory?

    var body: some View {
        List {
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(title: "All", isSelected: category == nil) { category = nil }
                        ForEach(AnnouncementCategory.allCases) { c in
                            CategoryChip(title: c.rawValue, isSelected: category == c) { category = c }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            Section("\(session.company?.community ?? "Community") Announcements") {
                ForEach(session.feed(category: category)) { announcement in
                    NavigationLink {
                        AnnouncementDetailView(announcement: announcement)
                    } label: {
                        AnnouncementRow(announcement: announcement, isRead: session.isRead(announcement))
                    }
                }
            }
        }
        .navigationTitle("Community")
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.vBlue : Color.white)
                .foregroundStyle(isSelected ? .white : Color.vText)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(isSelected ? Color.vBlue : Color.vBorder))
        }
        .buttonStyle(.plain)
    }
}

struct AnnouncementRow: View {
    let announcement: Announcement
    var isRead = true

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: announcement.category.icon)
                .foregroundStyle(Color.vTeal)
                .frame(width: 28, height: 28)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if announcement.isPinned {
                        Image(systemName: "pin.fill").font(.caption).foregroundStyle(Color.vBlue)
                    }
                    Text(announcement.title)
                        .font(.subheadline.weight(isRead ? .medium : .bold))
                        .foregroundStyle(Color.vText)
                }
                Text(announcement.body).font(.caption).foregroundStyle(Color.vSubtext).lineLimit(2)
                Text("\(announcement.category.rawValue) · \(announcement.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2).foregroundStyle(Color.vSubtext)
            }
            Spacer(minLength: 0)
            if !isRead {
                Circle().fill(Color.vBlue).frame(width: 8, height: 8).padding(.top, 6)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AnnouncementDetailView: View {
    @EnvironmentObject var session: AppSession
    let announcement: Announcement

    var body: some View {
        ScrollView {
            Card {
                Label(announcement.category.rawValue, systemImage: announcement.category.icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.vTeal)
                Text(announcement.title).font(.title2.bold()).foregroundStyle(Color.vText)
                Text("\(announcement.author) · \(announcement.date.formatted(date: .long, time: .omitted))")
                    .font(.footnote).foregroundStyle(Color.vSubtext)
                Divider()
                Text(announcement.body).font(.body).foregroundStyle(Color.vText)
            }
            .padding(16)
        }
        .background(Color.vBackground.ignoresSafeArea())
        .navigationTitle("Announcement")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { session.markRead(announcement) }
    }
}
