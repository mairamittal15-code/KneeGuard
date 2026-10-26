import SwiftUI
import Charts


struct ResultsView: View {

    let result:
        KneeGuardResult


    var body: some View {

        ZStack {

            backgroundColor
                .ignoresSafeArea()


            ScrollView {

                VStack(
                    alignment:
                        .leading,

                    spacing:
                        22
                ) {


                    // ====================================================
                    // TITLE
                    // ====================================================

                    Text(
                        "Your Landing"
                    )
                    .font(
                        .system(
                            size: 34,
                            weight: .bold,
                            design: .rounded
                        )
                    )


                    // ====================================================
                    // MOVEMENT SCORE
                    // ====================================================

                    VStack(
                        alignment:
                            .leading,

                        spacing:
                            10
                    ) {

                        Text(
                            "MOVEMENT SCORE · PROTOTYPE"
                        )
                        .font(
                            .caption.bold()
                        )
                        .foregroundStyle(
                            .secondary
                        )


                        HStack(
                            alignment:
                                .lastTextBaseline
                        ) {

                            Text(
                                "\(result.score)"
                            )
                            .font(
                                .system(
                                    size: 58,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )


                            Text(
                                "/ 100"
                            )
                            .font(
                                .title3
                            )
                            .foregroundStyle(
                                .secondary
                            )
                        }


                        Text(
                            "A custom movement-quality metric based on inward knee movement and left-right asymmetry."
                        )
                        .font(
                            .subheadline
                        )
                        .foregroundStyle(
                            .secondary
                        )


                        Text(
                            "This is an experimental feedback score, not a medical diagnosis or ACL injury prediction."
                        )
                        .font(
                            .caption
                        )
                        .foregroundStyle(
                            .secondary
                        )
                    }
                    .padding(
                        22
                    )
                    .frame(
                        maxWidth:
                            .infinity,

                        alignment:
                            .leading
                    )
                    .background(
                        .white
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius:
                                24
                        )
                    )


                    // ====================================================
                    // FOCUS
                    // ====================================================

                    VStack(
                        alignment:
                            .leading,

                        spacing:
                            10
                    ) {

                        Text(
                            "YOUR FOCUS"
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
                    .padding(
                        22
                    )
                    .frame(
                        maxWidth:
                            .infinity,

                        alignment:
                            .leading
                    )
                    .background(
                        Color.blue.opacity(
                            0.10
                        )
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius:
                                24
                        )
                    )


                    // ====================================================
                    // VISUAL LANDING FRAME
                    // ====================================================

                    if let image =
                        result.annotatedUIImage {

                        VStack(
                            alignment:
                                .leading,

                            spacing:
                                12
                        ) {

                            Text(
                                "Detected Landing"
                            )
                            .font(
                                .title3.bold()
                            )


                            Text(
                                "This is the frame KneeGuard identified as your initial landing. The lines show the detected hip, knee, and ankle positions."
                            )
                            .font(
                                .subheadline
                            )
                            .foregroundStyle(
                                .secondary
                            )


                            Image(
                                uiImage:
                                    image
                            )
                            .resizable()
                            .scaledToFit()
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius:
                                        18
                                )
                            )


                            HStack(
                                spacing:
                                    8
                            ) {

                                Image(
                                    systemName:
                                        "circle.fill"
                                )
                                .font(
                                    .system(
                                        size:
                                            8
                                    )
                                )
                                .foregroundStyle(
                                    .yellow
                                )


                                Text(
                                    "Yellow points = detected joints"
                                )
                                .font(
                                    .caption
                                )
                                .foregroundStyle(
                                    .secondary
                                )
                            }


                            Text(
                                "The displayed knee angles are calculated from the hip → knee → ankle landmarks."
                            )
                            .font(
                                .caption
                            )
                            .foregroundStyle(
                                .secondary
                            )
                        }
                        .padding(
                            20
                        )
                        .background(
                            .white
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius:
                                    24
                            )
                        )
                    }


                    // ====================================================
                    // LANDING DETAILS
                    // ====================================================

                    Text(
                        "Landing Details"
                    )
                    .font(
                        .title3.bold()
                    )


                    metricCard(

                        title:
                            "Left knee",

                        value:
                            String(
                                format:
                                    "%.1f%% inward",
                                result.leftInward
                            )
                    )


                    metricCard(

                        title:
                            "Right knee",

                        value:
                            String(
                                format:
                                    "%.1f%% inward",
                                result.rightInward
                            )
                    )


                    metricCard(

                        title:
                            "Left-right difference",

                        value:
                            String(
                                format:
                                    "%.1f°",
                                result.asymmetry
                            )
                    )


                    // ====================================================
                    // WHAT RESULTS MEAN
                    // ====================================================

                    Text(
                        "What This Means"
                    )
                    .font(
                        .title3.bold()
                    )


                    VStack(
                        alignment:
                            .leading,

                        spacing:
                            12
                    ) {

                        explanationRow(

                            icon:
                                "arrow.down.right.and.arrow.up.left",

                            title:
                                "Inward knee movement",

                            body:
                                "KneeGuard compares the horizontal position of your knee with your ankle and body center. Larger inward movement can indicate less controlled landing alignment."
                        )


                        Divider()


                        explanationRow(

                            icon:
                                "arrow.left.and.right",

                            title:
                                "Left-right difference",

                            body:
                                "A larger difference means your two legs handled the landing differently. KneeGuard uses this as a measure of movement asymmetry."
                        )
                    }
                    .padding(
                        20
                    )
                    .background(
                        .white
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius:
                                22
                        )
                    )


                    // ====================================================
                    // MOVEMENT GRAPH
                    // ====================================================

                    if !result.graph.isEmpty {

                        Text(
                            "Movement Around Landing"
                        )
                        .font(
                            .title3.bold()
                        )


                        VStack(
                            alignment:
                                .leading,

                            spacing:
                                12
                        ) {

                            Text(
                                "0 seconds represents the detected landing moment."
                            )
                            .font(
                                .caption
                            )
                            .foregroundStyle(
                                .secondary
                            )


                            Chart {

                                ForEach(
                                    result.graph
                                ) { point in

                                    LineMark(

                                        x:
                                            .value(
                                                "Time",
                                                point.time
                                            ),

                                        y:
                                            .value(
                                                "Left",
                                                point.left
                                            ),

                                        series:
                                            .value(
                                                "Side",
                                                "Left"
                                            )
                                    )
                                    .foregroundStyle(
                                        .blue
                                    )


                                    LineMark(

                                        x:
                                            .value(
                                                "Time",
                                                point.time
                                            ),

                                        y:
                                            .value(
                                                "Right",
                                                point.right
                                            ),

                                        series:
                                            .value(
                                                "Side",
                                                "Right"
                                            )
                                    )
                                    .foregroundStyle(
                                        .orange
                                    )
                                }


                                RuleMark(
                                    x:
                                        .value(
                                            "Landing",
                                            0
                                        )
                                )
                                .foregroundStyle(
                                    .secondary
                                )
                                .lineStyle(
                                    StrokeStyle(
                                        lineWidth:
                                            1,

                                        dash:
                                            [
                                                4,
                                                4
                                            ]
                                    )
                                )
                            }
                            .frame(
                                height:
                                    230
                            )


                            HStack(
                                spacing:
                                    20
                            ) {

                                legendItem(

                                    color:
                                        .blue,

                                    text:
                                        "Left"
                                )


                                legendItem(

                                    color:
                                        .orange,

                                    text:
                                        "Right"
                                )
                            }
                        }
                        .padding(
                            20
                        )
                        .background(
                            .white
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius:
                                    22
                            )
                        )
                    }


                    // ====================================================
                    // TRAINING PLAN
                    // ====================================================

                    Text(
                        "Training Plan"
                    )
                    .font(
                        .title3.bold()
                    )


                    ForEach(
                        Array(
                            result.exercises.enumerated()
                        ),
                        id:
                            \.element.id
                    ) { index, exercise in

                        HStack(
                            alignment:
                                .top,

                            spacing:
                                14
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
                                width:
                                    34,

                                height:
                                    34
                            )
                            .background(
                                Color.blue
                            )
                            .clipShape(
                                Circle()
                            )


                            VStack(
                                alignment:
                                    .leading,

                                spacing:
                                    7
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
                                .fontWeight(
                                    .semibold
                                )
                                .foregroundStyle(
                                    .blue
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
                        .padding(
                            18
                        )
                        .background(
                            .white
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius:
                                    18
                            )
                        )
                    }


                    // ====================================================
                    // TECHNICAL DETAILS
                    // ====================================================

                    DisclosureGroup(
                        "Analysis Details"
                    ) {

                        VStack(
                            alignment:
                                .leading,

                            spacing:
                                10
                        ) {

                            technicalRow(

                                title:
                                    "Takeoff",

                                value:
                                    String(
                                        format:
                                            "%.2f s",
                                        result.takeoffTime
                                    )
                            )


                            technicalRow(

                                title:
                                    "Jump apex",

                                value:
                                    String(
                                        format:
                                            "%.2f s",
                                        result.apexTime
                                    )
                            )


                            technicalRow(

                                title:
                                    "Landing",

                                value:
                                    String(
                                        format:
                                            "%.2f s",
                                        result.landingTime
                                    )
                            )


                            Divider()


                            technicalRow(

                                title:
                                    "Pose tracking",

                                value:
                                    String(
                                        format:
                                            "%.0f%%",
                                        result.poseTracking
                                    )
                            )


                            technicalRow(

                                title:
                                    "Usable lower body",

                                value:
                                    String(
                                        format:
                                            "%.0f%%",
                                        result.lowerBodyTracking
                                    )
                            )
                        }
                        .padding(
                            .top,
                            12
                        )
                    }
                    .padding(
                        18
                    )
                    .background(
                        .white
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius:
                                18
                        )
                    )


                    // IMPORTANT:
                    // Keeps final content from sitting behind tab bar.

                    Spacer(
                        minLength:
                            120
                    )
                }
                .padding()
            }
        }
        .navigationTitle(
            "Results"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }


    // ========================================================
    // COLORS
    // ========================================================

    private var backgroundColor:
        Color {

        Color(

            red:
                0.97,

            green:
                0.97,

            blue:
                0.95
        )
    }


    // ========================================================
    // METRIC CARD
    // ========================================================

    private func metricCard(

        title:
            String,

        value:
            String

    ) -> some View {

        HStack {

            Text(
                title
            )
            .fontWeight(
                .semibold
            )


            Spacer()


            Text(
                value
            )
            .foregroundStyle(
                .secondary
            )
        }
        .padding(
            18
        )
        .background(
            .white
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius:
                    18
            )
        )
    }


    // ========================================================
    // EXPLANATION ROW
    // ========================================================

    private func explanationRow(

        icon:
            String,

        title:
            String,

        body:
            String

    ) -> some View {

        HStack(
            alignment:
                .top,

            spacing:
                14
        ) {

            Image(
                systemName:
                    icon
            )
            .foregroundStyle(
                .blue
            )
            .font(
                .title3
            )
            .frame(
                width:
                    30
            )


            VStack(
                alignment:
                    .leading,

                spacing:
                    5
            ) {

                Text(
                    title
                )
                .font(
                    .headline
                )


                Text(
                    body
                )
                .font(
                    .subheadline
                )
                .foregroundStyle(
                    .secondary
                )
            }
        }
    }


    // ========================================================
    // TECHNICAL ROW
    // ========================================================

    private func technicalRow(

        title:
            String,

        value:
            String

    ) -> some View {

        HStack {

            Text(
                title
            )


            Spacer()


            Text(
                value
            )
            .foregroundStyle(
                .secondary
            )
        }
        .font(
            .subheadline
        )
    }


    // ========================================================
    // GRAPH LEGEND
    // ========================================================

    private func legendItem(

        color:
            Color,

        text:
            String

    ) -> some View {

        HStack(
            spacing:
                6
        ) {

            Circle()
                .fill(
                    color
                )
                .frame(
                    width:
                        8,

                    height:
                        8
                )


            Text(
                text
            )
            .font(
                .caption
            )
            .foregroundStyle(
                .secondary
            )
        }
    }
}
