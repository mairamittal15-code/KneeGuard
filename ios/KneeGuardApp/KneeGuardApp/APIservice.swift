import Foundation

enum APIServiceError: Error, LocalizedError {

    case invalidResponse
    case server(String)

    var errorDescription: String? {

        switch self {

        case .invalidResponse:
            return "KneeGuard received an invalid response from the analysis server."

        case .server(let message):
            return message
        }
    }
}


final class APIService {

    static let shared = APIService()

    private init() {}


    func analyze(
        videoURL: URL
    ) async throws -> KneeGuardResult {

        print("1. STARTING ANALYSIS")
        print("VIDEO URL:", videoURL)

        guard let url = URL(
            string: "http://YOURLOCALIP:8000/analyze"
        ) else {
            throw APIServiceError.invalidResponse
        }

        print("2. SERVER URL:", url.absoluteString)

        print("3. READING VIDEO")

        let videoData = try Data(
            contentsOf: videoURL
        )

        print(
            "4. VIDEO LOADED:",
            Double(videoData.count) / 1_000_000,
            "MB"
        )

        let boundary =
            "Boundary-\(UUID().uuidString)"

        var body = Data()

        body.appendString(
            "--\(boundary)\r\n"
        )

        body.appendString(
            "Content-Disposition: form-data; name=\"video\"; filename=\"landing.mov\"\r\n"
        )

        body.appendString(
            "Content-Type: video/quicktime\r\n\r\n"
        )

        body.append(videoData)

        body.appendString(
            "\r\n--\(boundary)--\r\n"
        )

        print("5. MULTIPART BODY CREATED")

        var request = URLRequest(
            url: url
        )

        request.httpMethod = "POST"

        request.timeoutInterval = 300

        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        print("6. ABOUT TO SEND REQUEST")

        let configuration =
            URLSessionConfiguration.default

        configuration.timeoutIntervalForRequest = 300
        configuration.timeoutIntervalForResource = 300

        let session = URLSession(
            configuration: configuration
        )

        let (
            data,
            response
        ) = try await session.upload(
            for: request,
            from: body
        )

        print("7. SERVER RESPONDED")

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw APIServiceError.invalidResponse
        }

        print(
            "8. STATUS CODE:",
            httpResponse.statusCode
        )

        if !(200...299).contains(
            httpResponse.statusCode
        ) {

            if let serverError =
                try? JSONDecoder().decode(
                    APIErrorResponse.self,
                    from: data
                ) {

                throw APIServiceError.server(
                    serverError.error
                )
            }

            if let responseText = String(
                data: data,
                encoding: .utf8
            ) {
                print(
                    "SERVER ERROR RESPONSE:",
                    responseText
                )
            }

            throw APIServiceError.invalidResponse
        }

        print("9. DECODING KNEEGUARD RESULT")

        let result =
            try JSONDecoder().decode(
                KneeGuardResult.self,
                from: data
            )

        print("10. ANALYSIS COMPLETE")

        return result
    }
}


// MARK: - Multipart helper

extension Data {

    mutating func appendString(
        _ string: String
    ) {

        if let data = string.data(
            using: .utf8
        ) {

            append(data)
        }
    }
}
