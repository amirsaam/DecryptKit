//
//  PatreonCampaignDetails.swift
//  deCripple
//
//  Created by Amir Mohammadi on 10/24/1401 AP.
//

import SwiftUI
import Neumorphic

struct PatreonCampaignDetails: View {

  @Binding var patreonCampaign: PatreonCampaignInfo?

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
            Text("DecryptKit")
              .font(.headline)
            Text(patreonCampaign?.data.attributes.creation_name ?? "")
              .font(.caption)
          }
        }
        HStack(spacing: 5) {
          Text(patreonCampaign?.data.attributes.is_monthly ?? true ? "Monthly Subscription" : "One Time Pay")
          Divider()
            .frame(height: 10)
          Text("Patrons Count: \(patreonCampaign?.data.attributes.patron_count ?? 0)")
        }
        .font(.caption)
      }
    }
}
