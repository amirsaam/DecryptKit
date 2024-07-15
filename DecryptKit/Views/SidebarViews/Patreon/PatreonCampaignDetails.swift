//
//  PatreonCampaignDetails.swift
//  deCripple
//
//  Created by Amir Mohammadi on 10/24/1401 AP.
//

import SwiftUI
import Neumorphic
import RealmSwift
import CachedAsyncImage
import PatreonAPI

struct PatreonCampaignDetails: View {

  @State var user: User
  @Binding var patreonCampaign: PatreonCampaignInfo?
  @Binding var patreonTiers: [CampaignIncludedTier]
  @Binding var patreonBenefits: [CampaignIncludedBenefit]
  @Binding var patronMembership: [UserIdentityIncludedMembership]

  @ObservedResults(deUser.self) private var users
  @State private var newUser = deUser()

  @State private var patreonVM = PatreonVM.shared
  @State private var presentSubscribeAlert = false
  @State private var pledgeUrlToShow: URL?

  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
      HStack(spacing: 10) {
        Image("DecryptKit")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 50, height: 50)
          .cornerRadius(12)
          .softOuterShadow()
        VStack(alignment: .leading, spacing: 5) {
          Text(patreonCampaign?.data.attributes.vanity ?? "")
            .font(.headline)
          Text(patreonCampaign?.data.attributes.creation_name ?? "")
            .font(.caption)
        }
      }
      HStack(spacing: 5) {
        Text(patreonCampaign?.data.attributes.is_monthly ?? true ? "Monthly Subscription" : "One Time Pay")
        Divider()
          .frame(height: 10)
        Text("Total Patrons: \(patreonCampaign?.data.attributes.patron_count ?? 0)")
      }
      .font(.caption)
      VStack {
        ForEach(patreonTiers.dropFirst(), id: \.id) { tier in
          let formattedPrice = String(format: "$%.2f", Double(tier.attributes.amount_cents) / 100)
          VStack(alignment: .leading) {
            HStack(spacing: 10) {
              CachedAsyncImage(url: URL(string: tier.attributes.image_url ?? "ProgressForEver")) { image in
                image
                  .resizable()
                  .aspectRatio(contentMode: .fit)
              } placeholder: {
                Rectangle()
                  .fill(mainColor)
                  .overlay {
                    ProgressView()
                  }
              }
              .frame(width: 40, height: 40)
              .cornerRadius(12)
              .softOuterShadow()
              VStack(alignment: .leading, spacing: 5) {
                Text(tier.attributes.title)
                  .font(.subheadline)
                Text("Patrons: \(tier.attributes.patron_count)")
                  .font(.caption)
              }
              Spacer()
              Button {
                pledgeUrlToShow = URL(string: "https://www.patreon.com" + tier.attributes.url)
                presentSubscribeAlert = true
              } label: {
                Group {
                  if patreonVM.userIsPatron && patreonVM.userSubscribedTierId == tier.id {
                    Label("Subscribed", systemImage: "signature")
                  } else {
                    Label(formattedPrice, systemImage: "arrow.up.right.square")
                  }
                }
                .font(.caption2.bold())
              }
              .softButtonStyle(
                RoundedRectangle(cornerRadius: 10),
                padding: 10,
                mainColor: .red,
                textColor: .white,
                darkShadowColor: .redNeuDS,
                lightShadowColor: .redNeuLS,
                pressedEffect: .flat
              )
              .disabled(patreonVM.userIsPatron)
              .alert("Kindly Take Heed", isPresented: $presentSubscribeAlert) {
                Button("Open Patreon", role: .none) {
                  if let url = pledgeUrlToShow {
                    UIApplication.shared.open(url)
                  }
                }
                Button("Cancel", role: .cancel) { return }
              } message: {
                Text("Should you opt to grace us with your subscription, kindly note that a restart of the DecryptKit application will be required for the changes to take effect.")
              }
            }
            Text("Benefits:")
              .font(.caption)
              .padding(.top, 1)
            let tierBenefits = patreonBenefits.filter { benefit in
              let data = benefit.relationships.tiers.data
              let containsId = data.contains { relatedTier in
                relatedTier.id == tier.id
              }
              return containsId
            }
            VStack(alignment: .leading) {
              ForEach(tierBenefits, id: \.id) { benefit in
                Label(benefit.attributes.title, systemImage: "checkmark.circle.fill")
                  .font(.caption2)
                  .padding(.leading)
              }
            }
            .padding(.top, 1)
          }
          .padding(.top)
          .task {
            if patreonVM.userIsPatron && patreonVM.userSubscribedTierId == tier.id {
              let userTier = (formattedPrice == "$2.99" ? 1 : formattedPrice == "$4.99" ? 2 : 3)
              await handleSubscribedPatron(tier: userTier)
            }
          }
        }
      }
    }
  }
  
  func handleSubscribedPatron(tier: Int) async {
    let realm = users.realm!.thaw()
    let thawedUsers = users.thaw()!
    let currentUser = thawedUsers.where {
      $0.userId.contains(user.id)
    }
    try! realm.write {
      currentUser[0].userTier = tier
    }
    UserVM.shared.userTier = tier
  }
}
