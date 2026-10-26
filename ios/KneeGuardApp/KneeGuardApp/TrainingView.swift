import SwiftUI


struct TrainingView: View {

    @EnvironmentObject var appState:
        AppState


    @State private var currentExercise =
        0


    var body: some View {

        NavigationStack {

            ZStack {

                Color(
                    red: 0.97,
                    green: 0.97,
                    blue: 0.95
                )
                .ignoresSafeArea()


                if let result =
                    appState.latestResult {

                    trainingContent(
                        result: result
                    )

                } else {

                    emptyState
                }
            }
            .navigationTitle(
                "Training"
            )
        }
    }


    private func trainingContent(
        result: KneeGuardResult
    ) -> some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 22
            ) {


                Text(
                    "Your Plan"
                )
                .font(
                    .system(
                        size: 34,
                        weight: .bold,
                        design: .rounded
                    )
                )


                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Text(
                        "PRIMARY FOCUS"
                    )
                    .font(
                        .caption.bold()
                    )
                    .foregroundStyle(
                        .secondary
                    )


                    Text(
                        result.focus
                    )
                    .font(
                        .title2.bold()
                    )


                    Text(
                        result.focusReason
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }
                .padding(20)
                .frame(
                    maxWidth:
                        .infinity,
                    alignment:
                        .leading
                )
                .background(
                    Color.blue.opacity(
                        0.09
                    )
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 22
                    )
                )


                Text(
                    "Today's exercises"
                )
                .font(
                    .title3.bold()
                )


                ForEach(
                    Array(
                        result.exercises
                            .enumerated()
                    ),
                    id: \.element.id
                ) { index, exercise in

                    HStack(
                        alignment: .top,
                        spacing: 14
                    ) {

                        Text(
                            "\(index + 1)"
                        )
                        .font(
                            .headline
                        )
                        .foregroundStyle(
                            .white
                        )
                        .frame(
                            width: 34,
                            height: 34
                        )
                        .background(
                            Color.blue
                        )
                        .clipShape(
                            Circle()
                        )


                        VStack(
                            alignment: .leading,
                            spacing: 7
                        ) {

                            Text(
                                exercise.name
                            )
                            .font(
                                .headline
                            )


                            Text(
                                exercise.volume
                            )
                            .foregroundStyle(
                                .blue
                            )
                            .fontWeight(
                                .semibold
                            )


                            Text(
                                exercise.instruction
                            )
                            .font(
                                .subheadline
                            )
                            .foregroundStyle(
                                .secondary
                            )
                        }


                        Spacer()
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


                Text(
                    "Try this routine 2–3 times per week. Reassess after about 1–2 weeks to see whether your movement becomes more consistent."
                )
                .font(
                    .footnote
                )
                .foregroundStyle(
                    .secondary
                )
                .padding(
                    .top,
                    8
                )


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
                    "figure.strengthtraining.traditional"
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
                "No training plan yet"
            )
            .font(
                .title2.bold()
            )


            Text(
                "Complete an assessment and your personalized exercises will appear here."
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
}
