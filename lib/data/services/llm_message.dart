class LlmMessage {
  final String role; // "user" | "assistant"
  final List<Map<String, dynamic>> parts;

  LlmMessage(this.role, String text)
      : parts = [
          {"text": text}
        ];

  Map<String, dynamic> toJson() => {
        "role": role,
        "parts": parts,
      };
}
