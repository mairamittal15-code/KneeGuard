import SwiftUI


struct ContentView: View {

    var body: some View {

        TabView {

            HomeView()
                .tabItem {

                    Label(
                        "Home",
                        systemImage:
                            "house.fill"
                    )
                }


            AssessmentView()
                .tabItem {

                    Label(
                        "Assess",
                        systemImage:
                            "camera.fill"
                    )
                }


            TrainingView()
                .tabItem {

                    Label(
                        "Training",
                        systemImage:
                            "figure.strengthtraining.traditional"
                    )
                }


            ProgressView()
                .tabItem {

                    Label(
                        "Progress",
                        systemImage:
                            "chart.line.uptrend.xyaxis"
                    )
                }
        }
        .tint(
            Color(
                red: 0.12,
                green: 0.55,
                blue: 0.91
            )
        )
    }
}
