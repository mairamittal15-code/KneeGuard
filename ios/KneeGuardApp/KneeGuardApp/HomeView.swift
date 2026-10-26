import SwiftUI


struct HomeView: View {

    @EnvironmentObject var appState:
        AppState


    var body: some View {

        NavigationStack {

            ZStack {

                backgroundColor
                    .ignoresSafeArea()


                ScrollView {

                    VStack(
                        alignment: .leading,
                        spacing: 24
                    ) {


                        // HEADER

                        VStack(
                            alignment: .leading,
                            spacing: 5
                        ) {

                            Text(
                                "KneeGuard"
                            )
                            .font(
                                .headline
                            )
                            .foregroundStyle(
                                .secondary
                            )


                            Text(
                                "Ready to check\nyour landing?"
                            )
                            .font(
                                .system(
                                    size: 38,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                        }


                        // NEW ASSESSMENT CARD

                        VStack(
                            alignment: .leading,
                            spacing: 16
                        ) {

                            Image(
                                systemName:
                                    "figure.run"
                            )
                            .font(
                                .system(
                                    size: 36
                                )
                            )
                            .foregroundStyle(
                                accentColor
                            )


                            Text(
                                "New Assessment"
                            )
                            .font(
                                .title2.bold()
                            )


                            Text(
                                "Record one jump and get feedback on your landing mechanics."
                            )
                            .foregroundStyle(
                                .secondary
                            )


                            NavigationLink {

                                AssessmentView()

                            } label: {

                                Text(
                                    "Start Assessment"
                                )
                                .fontWeight(
                                    .semibold
                                )
                                .frame(
                                    maxWidth:
                                        .infinity
                                )
                                .padding()
                                .background(
                                    accentColor
                                )
                                .foregroundStyle(
                                    .white
                                )
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 16
                                    )
                                )
                            }
                        }
                        .padding(22)
                        .background(
                            .white
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 24
                            )
                        )


                        // LATEST RESULT

                        Text(
                            "Recent"
                        )
                        .font(
                            .title3.bold()
                        )


                        if let result =
                            appState.latestResult {

                            NavigationLink {

                                ResultsView(
                                    result: result
                                )

                            } label: {

                                VStack(
                                    alignment: .leading,
                                    spacing: 16
                                ) {

                                    HStack {

                                        VStack(
                                            alignment: .leading,
                                            spacing: 4
                                        ) {

                                            Text(
                                                "Latest Assessment"
                                            )
                                            .font(
                                                .headline
                                            )


                                            Text(
                                                result.focus
                                            )
                                            .font(
                                                .subheadline
                                            )
                                            .foregroundStyle(
                                                .secondary
                                            )
                                        }


                                        Spacer()


                                        Text(
                                            "\(result.score)"
                                        )
                                        .font(
                                            .system(
                                                size: 38,
                                                weight: .bold,
                                                design: .rounded
                                            )
                                        )


                                        Text(
                                            "/100"
                                        )
                                        .foregroundStyle(
                                            .secondary
                                        )
                                    }


                                    Divider()


                                    HStack {

                                        Text(
                                            "View results"
                                        )

                                        Spacer()

                                        Image(
                                            systemName:
                                                "chevron.right"
                                        )
                                    }
                                    .fontWeight(
                                        .medium
                                    )
                                    .foregroundStyle(
                                        accentColor
                                    )
                                }
                                .padding(20)
                                .background(
                                    .white
                                )
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 20
                                    )
                                )
                            }
                            .buttonStyle(
                                .plain
                            )

                        } else {

                            VStack(
                                alignment: .leading,
                                spacing: 6
                            ) {

                                Text(
                                    "No assessments yet"
                                )
                                .font(
                                    .headline
                                )


                                Text(
                                    "Your latest results will appear here."
                                )
                                .foregroundStyle(
                                    .secondary
                                )
                            }
                            .frame(
                                maxWidth:
                                    .infinity,
                                alignment:
                                    .leading
                            )
                            .padding(20)
                            .background(
                                .white
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 20
                                )
                            )
                        }


                        // QUICK STATS

                        if let result =
                            appState.latestResult {

                            Text(
                                "At a glance"
                            )
                            .font(
                                .title3.bold()
                            )


                            HStack(
                                spacing: 12
                            ) {

                                quickStat(
                                    title:
                                        "Left",
                                    value:
                                        String(
                                            format:
                                                "%.1f%%",
                                            result.leftInward
                                        )
                                )


                                quickStat(
                                    title:
                                        "Right",
                                    value:
                                        String(
                                            format:
                                                "%.1f%%",
                                            result.rightInward
                                        )
                                )


                                quickStat(
                                    title:
                                        "Difference",
                                    value:
                                        String(
                                            format:
                                                "%.1f°",
                                            result.asymmetry
                                        )
                                )
                            }
                        }


                        Spacer(
                            minLength: 50
                        )
                    }
                    .padding()
                }
            }
        }
    }


    private var backgroundColor: Color {

        Color(
            red: 0.97,
            green: 0.97,
            blue: 0.95
        )
    }


    private var accentColor: Color {

        Color(
            red: 0.12,
            green: 0.55,
            blue: 0.91
        )
    }


    private func quickStat(
        title: String,
        value: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            Text(
                title
            )
            .font(
                .caption
            )
            .foregroundStyle(
                .secondary
            )


            Text(
                value
            )
            .font(
                .headline
            )
        }
        .frame(
            maxWidth:
                .infinity,
            alignment:
                .leading
        )
        .padding(14)
        .background(
            .white
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
    }
}
