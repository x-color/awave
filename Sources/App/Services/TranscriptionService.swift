import Foundation

protocol TranscriptionServiceProtocol: AnyObject {
  func transcribe(audioURL: URL, baseURL: URL, model: String) async throws -> String
}

final class TranscriptionService: TranscriptionServiceProtocol, @unchecked Sendable {
  private let session: URLSession

  init(
    session: URLSession = .shared
  ) {
    self.session = session
  }

  func transcribe(audioURL: URL, baseURL: URL, model: String) async throws -> String {
    let endpoint = baseURL.appendingPathComponent("v1/audio/transcriptions")

    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"

    let boundary = UUID().uuidString
    request.setValue(
      "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    let audioData = try Data(contentsOf: audioURL)
    let body = createMultipartBody(
      audioData: audioData,
      audioFilename: audioURL.lastPathComponent,
      boundary: boundary,
      model: model
    )
    request.httpBody = body

    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw TranscriptionError.invalidResponse
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      throw TranscriptionError.serverError(statusCode: httpResponse.statusCode)
    }

    let transcriptionResponse = try JSONDecoder().decode(TranscriptionResponse.self, from: data)
    return transcriptionResponse.text
  }

  private func createMultipartBody(
    audioData: Data,
    audioFilename: String,
    boundary: String,
    model: String
  ) -> Data {
    var body = Data()

    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append(
      "Content-Disposition: form-data; name=\"file\"; filename=\"\(audioFilename)\"\r\n".data(
        using: .utf8)!)
    body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
    body.append(audioData)
    body.append("\r\n".data(using: .utf8)!)

    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
    body.append("\(model)\r\n".data(using: .utf8)!)

    body.append("--\(boundary)--\r\n".data(using: .utf8)!)

    return body
  }
}

struct TranscriptionResponse: Codable {
  let text: String
}

enum TranscriptionError: LocalizedError {
  case invalidResponse
  case serverError(statusCode: Int)

  var errorDescription: String? {
    switch self {
    case .invalidResponse:
      return "Invalid response from server."
    case .serverError(let statusCode):
      return "Server error with status code: \(statusCode)"
    }
  }
}
