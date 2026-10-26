import SwiftUI
import Combine

struct AssessmentRecord: Identifiable, Codable {

    let id: UUID
    let date: Date

    let score: Int
    let leftInward: Double
    let rightInward: Double
    let asymmetry: Double
    let focus: String


    init(result: KneeGuardResult) {

        id = UUID()
        date = Date()

        score = result.score
        leftInward = result.leftInward
        rightInward = result.rightInward
        asymmetry = result.asymmetry
        focus = result.focus
    }
}


@MainActor
final class AppState: ObservableObject {

    @Published var latestResult: KneeGuardResult?

    @Published var history: [AssessmentRecord] = []

    private let historyKey = "kneeGuardAssessmentHistory"


    init() {
        loadHistory()
    }


    func saveAssessment(_ result: KneeGuardResult) {

        latestResult = result

        let record = AssessmentRecord(
            result: result
        )

        history.append(record)

        saveHistory()
    }


    private func saveHistory() {

        guard let data = try? JSONEncoder().encode(history)
        else {
            return
        }

        UserDefaults.standard.set(
            data,
            forKey: historyKey
        )
    }


    private func loadHistory() {

        guard
            let data = UserDefaults.standard.data(
                forKey: historyKey
            ),
            let saved = try? JSONDecoder().decode(
                [AssessmentRecord].self,
                from: data
            )
        else {
            return
        }

        history = saved
    }
}
