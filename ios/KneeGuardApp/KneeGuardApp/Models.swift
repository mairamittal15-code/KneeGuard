import Foundation
import CoreTransferable
import UniformTypeIdentifiers
import UIKit


// ============================================================
// VIDEO SELECTED FROM PHOTOS
// ============================================================

struct Movie: Transferable {

    let url: URL


    static var transferRepresentation:
        some TransferRepresentation {

        FileRepresentation(
            contentType: .movie
        ) { movie in

            SentTransferredFile(
                movie.url
            )

        } importing: { received in

            let destination =
                FileManager
                .default
                .temporaryDirectory
                .appendingPathComponent(
                    UUID().uuidString
                    +
                    "-"
                    +
                    received.file.lastPathComponent
                )


            try FileManager.default.copyItem(

                at:
                    received.file,

                to:
                    destination
            )


            return Movie(
                url:
                    destination
            )
        }
    }
}


// ============================================================
// API RESULT
// ============================================================

struct KneeGuardResult: Codable {

    let score: Int

    let leftInward: Double
    let rightInward: Double

    let asymmetry: Double

    let takeoffTime: Double
    let apexTime: Double
    let landingTime: Double

    let poseTracking: Double
    let lowerBodyTracking: Double

    let focus: String
    let focusReason: String

    let exercises: [Exercise]

    let graph: [GraphPoint]

    let annotatedFrameBase64: String?


    enum CodingKeys:
        String,
        CodingKey {

        case score

        case leftInward =
            "left_inward"

        case rightInward =
            "right_inward"

        case asymmetry

        case takeoffTime =
            "takeoff_time"

        case apexTime =
            "apex_time"

        case landingTime =
            "landing_time"

        case poseTracking =
            "pose_tracking"

        case lowerBodyTracking =
            "lower_body_tracking"

        case focus

        case focusReason =
            "focus_reason"

        case exercises

        case graph

        case annotatedFrameBase64 =
            "annotated_frame_base64"
    }


    var annotatedUIImage:
        UIImage? {

        guard

            let annotatedFrameBase64,

            let data =
                Data(
                    base64Encoded:
                        annotatedFrameBase64
                )

        else {

            return nil
        }


        return UIImage(
            data:
                data
        )
    }
}


// ============================================================
// TRAINING EXERCISE
// ============================================================

struct Exercise:
    Codable,
    Identifiable {

    let name: String

    let volume: String

    let instruction: String


    var id: String {
        name
    }
}


// ============================================================
// GRAPH POINT
// ============================================================

struct GraphPoint:
    Codable,
    Identifiable {

    let time: Double

    let left: Double

    let right: Double


    var id: Double {
        time
    }
}


// ============================================================
// ERROR RESPONSE
// ============================================================

struct APIErrorResponse:
    Codable {

    let error: String
}
