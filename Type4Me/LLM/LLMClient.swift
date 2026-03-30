import Foundation

/// Common interface for LLM clients (OpenAI-compatible and Claude).
protocol LLMClient: Sendable {
    /// Process text and return the full result (non-streaming).
    func process(text: String, prompt: String, config: LLMConfig) async throws -> String
    /// Process text with streaming chunks. Calls onChunk for each incremental update.
    /// Returns the full accumulated result.
    func processStream(text: String, prompt: String, config: LLMConfig, onChunk: @Sendable @escaping (String) -> Void) async throws -> String
    func warmUp(baseURL: String) async
}

extension LLMClient {
    /// Default: fall back to non-streaming.
    func processStream(text: String, prompt: String, config: LLMConfig, onChunk: @Sendable @escaping (String) -> Void) async throws -> String {
        let result = try await process(text: text, prompt: prompt, config: config)
        onChunk(result)
        return result
    }
}

extension String {
    /// Remove `<think>...</think>` reasoning blocks emitted by models like DeepSeek.
    /// Handles both closed tags and unclosed/truncated tags.
    func strippingThinkTags() -> String {
        self
            .replacingOccurrences(of: "<think>[\\s\\S]*?</think>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "<think>[\\s\\S]*$", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
