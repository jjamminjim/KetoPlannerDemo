//
// AI.swift
// This actor wraps an on-device language model session and demonstrates Swift Concurrency features:
// actors, nonisolated members, and the @concurrent attribute.
//

import Foundation
import FoundationModels

/*
 [TP] Embedded LanguageModel (FoundationModels) — Uses & Abilities
 
 - On‑device by default: privacy-preserving, no network required; respects system policies.
 - Latency & efficiency: optimized for Apple silicon; good for short, interactive prompts.
 - Capabilities: text completion, summarization, rewriting, extraction/structuring, style transformation.
 - Instructions/system prompts: steer behavior with concise directives (as used below).
 - Safety & limits: avoid PII leakage; model size and context window constraints; deterministic-ish with temperature controls if available.
 - Session semantics: create lightweight `LanguageModelSession` objects; reuse or scope per request depending on prompt history needs.
 - Best practices: keep prompts short, provide examples, pre-validate inputs, post-validate outputs.
*/

/*
 [TP] An actor is a reference type with isolated state to prevent data races.
 All mutable state and methods are isolated to the actor unless marked `nonisolated`.
 Calls into actor-isolated methods are `await`ed to hop to the actor executor.
*/
actor AIEngine {
    // [TP] `nonisolated` makes this constant accessible without hopping to the actor.
    // Use it for pure, immutable, or thread-safe members, such as static-like metadata.
    // It can be read from any thread without `await`.
    nonisolated let appVersion = "1.0"

    // This is an actor-isolated synchronous function (no `async`) that can be called only from within
    // the actor or via `await` from outside.
    // It checks model availability and constructs a `LanguageModelSession` with concise instructions.
    // Throwing here is appropriate to surface availability errors early.
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

    /*
     [TP] `@concurrent` on an actor method means it can be safely invoked concurrently.
     Swift may run multiple calls in parallel without serializing through the actor
     if the method does not touch isolated mutable state.

     Despite the attribute, the method body still executes on the actor when accessing isolated state;
     use it when the method is reentrant or independent of actor state.

     Reentrancy means that long `await`s allow other work to interleave; design for idempotence.

     Use `@concurrent` for stateless or read-only operations that can overlap.

     Demo talking points for LanguageModel:
     - On-device inference: consistent, private, fast.
     - Great for short completions and guardrailed assistants (like this keto helper).
     - Use system instructions to constrain style and scope.
     - Consider session reuse if you need conversational context; otherwise, stateless calls are fine.
    */
    @concurrent
    func complete(_ userText: String) async throws -> String {
        // Hop to the actor (since it’s actor-isolated) and await session creation.
        let s = try await makeSession()
        
        // Await the model’s async work and may suspend, allowing reentrancy.
        let r = try await s.respond(to: userText)
        
        // Return the model’s response text.
        return r.content
    }
}

// Shared singleton-like instance; actors are safe to share across tasks.
let AI = AIEngine()

