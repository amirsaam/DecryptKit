//
//  PatreonCampaignDetails.swift
//  deCripple
//
//  Created by Amir Mohammadi on 10/24/1401 AP.
//

import SwiftUI
import Neumorphic
import CachedAsyncImage
import PatreonAPI

struct PatreonCampaignDetails: View {
  
  @Binding var patreonCampaign: PatreonCampaignInfo?
  @Binding var patreonTiers: [CampaignIncludedTier]
  @Binding var patreonBenefits: [CampaignIncludedBenefit]

  var body: some View {
    if patreonCampaign == nil {
      BrandProgress(logoSize: 30)
    } else {
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
          Text("Total Patrons Count: \(patreonCampaign?.data.attributes.patron_count ?? 0)")
        }
        .font(.caption)
        VStack {
          ForEach(patreonTiers, id: \.id) { tier in
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
                  if let url = URL(string: "https://www.patreon.com" + tier.attributes.url) {
                    UIApplication.shared.open(url)
                  }
                } label: {
                  let formattedPrice = String(format: "$%.2f", Double(tier.attributes.amount_cents) / 100)
                  Label(formattedPrice, systemImage: "arrow.up.right.square")
                    .font(.caption2)
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
              }
              Text("Benefits:")
                .font(.caption)
                .padding(.top, 1)
              let price = tier.attributes.amount_cents / 100
              let tierBenefits = patreonBenefits.filter { benefit in
                benefit.attributes.tiers_count >= (price == 2 ? 3 : price == 4 && price != 2 ? 2 : 1)
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
          }
          .padding(.top)
        }
        .padding(.top)
      }
    }
  }
}
