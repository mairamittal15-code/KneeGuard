import SwiftUI
import Charts


struct ProgressView: View {

    @EnvironmentObject var appState:
        AppState


    var body: some View {

        NavigationStack {

            ZStack {

                Color(
                    red: 0.97,
                    green: 0.97,
                    blue: 0.95
                )
                .ignoresSafeArea()


                if appState.history.isEmpty {

                    emptyState

                } else {

                    progressContent
                }
            }
            .navigationTitle(
                "Progress"
            )
        }
    }


    private var progressContent:
        some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 22
            ) {


                Text(
                    "Your Progress"
                )
                .font(
                    .system(
                        size: 34,
                        weight: .bold,
                        design: .rounded
                    )
                )


                if let latest =
                    appState.history.last {

                    HStack(
                        spacing: 12
                    ) {

                        statCard(
                            title:
                                "Latest",
                            value:
                                "\(latest.score)"
                        )


                        statCard(
                            title:
                                "Assessments",
                            value:
                                "\(appState.history.count)"
                        )
                    }
                }


                // SCORE GRAPH

                VStack(
                    alignment: .leading,
                    spacing: 14
                ) {

                    Text(
                        "Movement score"
                    )
                    .font(
                        .title3.bold()
                    )


                    Chart(
                        appState.history
                    ) { record in

                        LineMark(
                            x:
                                .value(
                                    "Date",
                                    record.date
                                ),

                            y:
                                .value(
                                    "Score",
                                    record.score
                                )
                        )


                        PointMark(
                            x:
                                .value(
                                    "Date",
                                    record.date
                                ),

                            y:
                                .value(
                                    "Score",
                                    record.score
                                )
                        )
                    }
                    .frame(
                        height: 220
                    )
                    .chartYScale(
                        domain: 0...100
                    )
                }
                .padding(20)
                .background(
                    .white
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 22
                    )
                )


                if let latest =
                    appState.history.last {

                    Text(
                        "Latest assessment"
                    )
                    .font(
                        .title3.bold()
                    )


                    detailRow(
                        title:
                            "Left inward movement",
                        value:
                            String(
                                format:
                                    "%.1f%%",
                                latest.leftInward
                            )
                    )


                    detailRow(
                        title:
                            "Right inward movement",
                        value:
                            String(
                                format:
                                    "%.1f%%",
                                latest.rightInward
                            )
                    )


                    detailRow(
                        title:
                            "Left-right difference",
                        value:
                            String(
                                format:
                                    "%.1f°",
                                latest.asymmetry
                            )
                    )


                    detailRow(
                        title:
                            "Current focus",
                        value:
                            latest.focus
                    )
                }


                if appState.history.count >= 2 {

                    let first =
                        appState.history.first!

                    let latest =
                        appState.history.last!


                    Text(
                        "Since your first assessment"
                    )
                    .font(
                        .title3.bold()
                    )


                    detailRow(
                        title:
                            "Score change",
                        value:
                            String(
                                format:
                                    "%+d",
                                latest.score
                                -
                                first.score
                            )
                    )


                    detailRow(
                        title:
                            "Left movement change",
                        value:
                            String(
                                format:
                                    "%+.1f%%",
                                latest.leftInward
                                -
                                first.leftInward
                            )
                    )


                    detailRow(
                        title:
                            "Right movement change",
                        value:
                            String(
                                format:
                                    "%+.1f%%",
                                latest.rightInward
                                -
                                first.rightInward
                            )
                    )
                }


                Spacer(
                    minLength: 100
                )
            }
            .padding()
        }
    }


    private var emptyState:
        some View {

        VStack(
            spacing: 16
        ) {

            Image(
                systemName:
                    "chart.line.uptrend.xyaxis"
            )
            .font(
                .system(
                    size: 48
                )
            )
            .foregroundStyle(
                .blue
            )


            Text(
                "No progress data yet"
            )
            .font(
                .title2.bold()
            )


            Text(
                "Complete an assessment to start tracking your movement over time."
            )
            .foregroundStyle(
                .secondary
            )
            .multilineTextAlignment(
                .center
            )
            .padding(
                .horizontal,
                30
            )
        }
    }


    private func statCard(
        title: String,
        value: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 5
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
                .system(
                    size: 32,
                    weight: .bold,
                    design: .rounded
                )
            )
        }
        .frame(
            maxWidth:
                .infinity,
            alignment:
                .leading
        )
        .padding(18)
        .background(
            .white
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18
            )
        )
    }


    private func detailRow(
        title: String,
        value: String
    ) -> some View {

        HStack {

            Text(
                title
            )
            .fontWeight(
                .medium
            )


            Spacer()


            Text(
                value
            )
            .foregroundStyle(
                .secondary
            )
            .multilineTextAlignment(
                .trailing
            )
        }
        .padding(18)
        .background(
            .white
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18
            )
        )
    }
}
