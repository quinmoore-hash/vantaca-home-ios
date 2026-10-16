import SwiftUI

struct SelectCompanyView: View {
    @EnvironmentObject var session: AppSession
    @State private var search = ""
    @State private var selected: ManagementCompany?

    private var filtered: [ManagementCompany] {
        guard !search.isEmpty else { return MockData.companies }
        return MockData.companies.filter {
            $0.name.localizedCaseInsensitiveContains(search) || $0.community.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        ScrollView {
            Card {
                Text("Select Management Company")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.vText)
                Text("You've successfully logged in! Your Login and Password are used in multiple management companies. Please select from the options below to continue.")
                    .font(.subheadline)
                    .foregroundStyle(Color.vSubtext)

                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(Color.vSubtext)
                    TextField("Search", text: $search)
                }
                .boxed()

                ForEach(filtered) { company in
                    Button { selected = company } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(company.name).font(.subheadline.weight(.semibold)).foregroundStyle(Color.vText)
                            HStack(spacing: 4) {
                                Text(company.community).foregroundStyle(Color.vSubtext)
                                if company.extraCommunities > 0 {
                                    Text("+\(company.extraCommunities)").foregroundStyle(Color.vBlue)
                                }
                            }
                            .font(.footnote)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(selected == company ? Color.vBlue.opacity(0.07) : Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 6)
                            .stroke(selected == company ? Color.vBlue : Color.vBorder, lineWidth: selected == company ? 1.5 : 1))
                    }
                }

                PrimaryButton(title: "Continue", disabled: selected == nil) {
                    if let selected { session.choose(selected) }
                }
                .padding(.top, 8)

                Button("Log Out") { session.logOut() }
                    .font(.footnote.weight(.medium))
                    .underline()
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
        }
        .background(Color.vBackground.ignoresSafeArea())
    }
}
