import SwiftUI
import PhotosUI


struct AssessmentView: View {

    @EnvironmentObject var appState:
        AppState


    @State private var selectedItem:
        PhotosPickerItem?


    @State private var selectedMovie:
        Movie?


    @State private var isAnalyzing =
        false


    @State private var errorMessage:
        String?


    @State private var result:
        KneeGuardResult?


    @State private var showResults =
        false


    var body: some View {

        NavigationStack {

            ZStack {

                Color(
                    red: 0.97,
                    green: 0.97,
                    blue: 0.95
                )
                .ignoresSafeArea()


                ScrollView {

                    VStack(
                        alignment: .leading,
                        spacing: 24
                    ) {


                        Text(
                            "New Assessment"
                        )
                        .font(
                            .system(
                                size: 34,
                                weight: .bold,
                                design: .rounded
                            )
                        )


                        Text(
                            "Upload a front-facing jump video. Keep your full body and both feet visible."
                        )
                        .foregroundStyle(
                            .secondary
                        )


                        // HOW TO RECORD

                        VStack(
                            alignment: .leading,
                            spacing: 12
                        ) {

                            Text(
                                "For the best analysis"
                            )
                            .font(
                                .headline
                            )


                            instruction(
                                number: "1",
                                text:
                                    "Place the camera directly in front of you."
                            )


                            instruction(
                                number: "2",
                                text:
                                    "Keep your entire body and both feet visible."
                            )


                            instruction(
                                number: "3",
                                text:
                                    "Stand still briefly, jump once, then hold your landing."
                            )
                        }
                        .padding(20)
                        .background(
                            Color.blue.opacity(
                                0.07
                            )
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 20
                            )
                        )


                        // PICKER

                        VStack(
                            spacing: 18
                        ) {

                            Image(
                                systemName:
                                    selectedMovie == nil
                                    ? "video.badge.plus"
                                    : "checkmark.circle.fill"
                            )
                            .font(
                                .system(
                                    size: 44
                                )
                            )
                            .foregroundStyle(
                                selectedMovie == nil
                                ? Color.blue
                                : Color.green
                            )


                            Text(
                                selectedMovie == nil
                                ? "Choose a landing video"
                                : "Video ready"
                            )
                            .font(
                                .headline
                            )


                            if selectedMovie != nil {

                                Text(
                                    "Your video is ready to analyze."
                                )
                                .font(
                                    .subheadline
                                )
                                .foregroundStyle(
                                    .secondary
                                )
                            }


                            PhotosPicker(
                                selection:
                                    $selectedItem,
                                matching:
                                    .videos
                            ) {

                                Text(
                                    selectedMovie == nil
                                    ? "Choose Video"
                                    : "Choose Different Video"
                                )
                                .frame(
                                    maxWidth:
                                        .infinity
                                )
                                .padding()
                                .background(
                                    Color.blue.opacity(
                                        0.12
                                    )
                                )
                                .foregroundStyle(
                                    .blue
                                )
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 14
                                    )
                                )
                            }
                        }
                        .padding(22)
                        .frame(
                            maxWidth:
                                .infinity
                        )
                        .background(
                            .white
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 24
                            )
                        )


                        if let errorMessage {

                            Text(
                                errorMessage
                            )
                            .foregroundStyle(
                                .red
                            )
                            .padding()
                            .frame(
                                maxWidth:
                                    .infinity,
                                alignment:
                                    .leading
                            )
                            .background(
                                Color.red.opacity(
                                    0.08
                                )
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 14
                                )
                            )
                        }


                        Button {

                            analyzeVideo()

                        } label: {

                            HStack {

                                if isAnalyzing {

                                    ProgressView()
                                        .tint(
                                            .white
                                        )
                                }


                                Text(
                                    isAnalyzing
                                    ? "Analyzing..."
                                    : "Analyze Landing"
                                )
                                .fontWeight(
                                    .semibold
                                )
                            }
                            .frame(
                                maxWidth:
                                    .infinity
                            )
                            .padding()
                            .background(
                                selectedMovie == nil
                                ? Color.gray
                                : Color.blue
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
                        .disabled(
                            selectedMovie == nil
                            ||
                            isAnalyzing
                        )


                        Spacer(
                            minLength: 60
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle(
                "Assess"
            )
            .navigationBarTitleDisplayMode(
                .inline
            )

            .onChange(
                of: selectedItem
            ) { _, newItem in

                Task {

                    do {

                        selectedMovie =
                            try await newItem?
                            .loadTransferable(
                                type:
                                    Movie.self
                            )

                        errorMessage =
                            nil

                    } catch {

                        errorMessage =
                            "Could not load that video."
                    }
                }
            }

            .navigationDestination(
                isPresented:
                    $showResults
            ) {

                if let result {

                    ResultsView(
                        result:
                            result
                    )
                }
            }
        }
    }


    private func analyzeVideo() {

        guard let movie =
                selectedMovie
        else {
            return
        }


        isAnalyzing =
            true

        errorMessage =
            nil


        Task {

            do {

                let response =
                    try await APIService.shared
                    .analyze(
                        videoURL:
                            movie.url
                    )


                await MainActor.run {

                    result =
                        response


                    // THIS IS THE IMPORTANT NEW PART

                    appState.saveAssessment(
                        response
                    )


                    isAnalyzing =
                        false


                    showResults =
                        true
                }


            } catch {

                await MainActor.run {

                    isAnalyzing =
                        false


                    errorMessage =
                        error.localizedDescription
                }
            }
        }
    }


    private func instruction(
        number: String,
        text: String
    ) -> some View {

        HStack(
            alignment: .top,
            spacing: 12
        ) {

            Text(
                number
            )
            .font(
                .caption.bold()
            )
            .foregroundStyle(
                .white
            )
            .frame(
                width: 24,
                height: 24
            )
            .background(
                Color.blue
            )
            .clipShape(
                Circle()
            )


            Text(
                text
            )
            .font(
                .subheadline
            )
        }
    }
}
