
import Foundation
import FoundationModels

actor AIEngine {
    nonisolated let appVersion = "1.0"

    private func makeSession() throws -> LanguageModelSession {
        guard SystemLanguageModel.default.isAvailable else {
            throw NSError(domain: "AIEngine", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "On-device model unavailable."])
        }
        
        return LanguageModelSession(
            instructions: """
            You are a concise keto assistant. Keep meals ≤ 20g net carbs.
            Avoid sugar, grains, starchy vegetables. Prefer whole foods.
            Keep answers short for a live demo.
            """
        )
    }

    @concurrent
    func complete(_ userText: String) async throws -> String {
        let s = try await makeSession()
        let r = try await s.respond(to: userText)
        return r.content
    }
}

let AI = AIEngine()
