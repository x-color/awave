import Alamofire
import Foundation

protocol TranscriptionServiceProtocol: AnyObject {
  func transcribe(audioURL: URL, baseURL: URL, model: String, apiKey: String?) async throws
    -> String
}

final class TranscriptionService: TranscriptionServiceProtocol, Sendable {
  private let session: Session

  init(session: Session = .default) {
    self.session = session
  }

  func transcribe(audioURL: URL, baseURL: URL, model: String, apiKey: String?) async throws
    -> String
  {
    let endpoint = baseURL.appendingPathComponent("v1/audio/transcriptions")

    return
      try await session
      .upload(
        multipartFormData: { $0.build(audioURL: audioURL, model: model) },
        to: endpoint,
        headers: .authorization(apiKey: apiKey)
      )
      .serializingDecodable(TranscriptionResponse.self)
      .value
      .text
  }
}

extension MultipartFormData {
  fileprivate func build(audioURL: URL, model: String) {
    append(
      audioURL,
      withName: "file",
      fileName: audioURL.lastPathComponent,
      mimeType: "audio/wav",
    )
    append(Data(model.utf8), withName: "model")
  }
}

extension HTTPHeaders {
  fileprivate static func authorization(apiKey: String?) -> HTTPHeaders {
    guard let apiKey, !apiKey.isEmpty else { return [] }
    return [.authorization(bearerToken: apiKey)]
  }
}

private struct TranscriptionResponse: Decodable {
  let text: String
}

enum TranscriptionError: LocalizedError {
  case serverError(statusCode: Int, message: String?)

  var errorDescription: String? {
    switch self {
    case .serverError(let statusCode, let message):
      return "Server error (\(statusCode)): \(message ?? "No details provided")"
    }
  }
}
