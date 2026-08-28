//
//  WelcomeView.swift
//  vestiaire
//
//  Created by Zubia Tahseen on 2026-06-10.
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage("userName") private var userName = ""
    @State private var name = ""

    var body: some View {
        ZStack {
            Color.ivory.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 12) {
                    Text("V")
                        .font(.system(size: 64, design: .serif))
                        .foregroundColor(Color.camel)
                    Text("Vestiaire")
                        .font(.system(size: 40, design: .serif))
                        .foregroundColor(Color.ink)
                    Text("Your wardrobe, dressed by the weather")
                }
                Spacer()

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("YOUR NAME")
                            .font(.system(size: 11, weight: .medium))
                            .kerning(1.1)
                            .foregroundStyle(Color.stone)
                        TextField("e.g. Zubia", text: $name)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.linen, lineWidth: 1)
                            )

                    }

                    Button {
                        userName = name.trimmingCharacters(in: .whitespaces)
                    } label: {
                        Text("Start building my wardrobe")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.ivory)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.ink)
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                        }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)

                    Text("Sign in & accounts coming in v2")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.stone)

                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}

#Preview {
    WelcomeView()
}
