// lib/screens/chat_ai_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/pages/detail_screen.dart';

// ===== SERVICE =====
import '../data/services/gemini_chat_service.dart';
import '../data/services/tour_search_service.dart';
import '../data/services/itinerary_service.dart';

// ===== CARD WIDGETS =====
import '../widget/discount_tour_card.dart';
import '../widget/budget_tour_card.dart';
import '../widget/duration_tour_card.dart';
import '../widget/cheap_tour_card.dart';

// ========================================================
// ENUM
// ========================================================
enum MessageType {
  user,
  aiText,
  aiDiscountTours,
  aiBudgetTours,
  aiDurationTours,
  aiCheapTours,
  aiItinerary,
}

// ========================================================
// MESSAGE MODELS
// ========================================================
class Message {
  final MessageType type;
  final String text;
  Message(this.type, this.text);

  Message.user(String t) : this(MessageType.user, t);
  Message.aiText(String t) : this(MessageType.aiText, t);
}

class MessageDiscountTours extends Message {
  final List<Map<String, dynamic>> tours;
  MessageDiscountTours(this.tours) : super(MessageType.aiDiscountTours, "");
}

class MessageBudgetTours extends Message {
  final List<Map<String, dynamic>> tours;
  MessageBudgetTours(this.tours) : super(MessageType.aiBudgetTours, "");
}

class MessageDurationTours extends Message {
  final List<Map<String, dynamic>> tours;
  MessageDurationTours(this.tours) : super(MessageType.aiDurationTours, "");
}

class MessageCheapTours extends Message {
  final List<Map<String, dynamic>> tours;
  MessageCheapTours(this.tours) : super(MessageType.aiCheapTours, "");
}

class MessageAiItinerary extends Message {
  final List<Map<String, dynamic>> items;
  MessageAiItinerary(this.items) : super(MessageType.aiItinerary, "");
}

// ========================================================
// CHAT SCREEN
// ========================================================
class ChatAiScreen extends StatefulWidget {
  const ChatAiScreen({super.key});

  @override
  State<ChatAiScreen> createState() => _ChatAiScreenState();
}

class _ChatAiScreenState extends State<ChatAiScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  late final GeminiTravelService _gemini;
  late final TourSearchService _tourSearch;

  @override
  void initState() {
    super.initState();
    _gemini = GeminiTravelService();
    _tourSearch = TourSearchService();
  }

  void _autoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ========================================================
  // SEND MESSAGE
  // ========================================================
  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _messages.add(Message.user(text)));
    _controller.clear();
    _autoScroll();

    // ===== LLM HISTORY (không đưa meta vào UI) =====
    final history = <LlmMessage>[];
    for (final m in _messages) {
      if (m is MessageDiscountTours) {
        history.add(LlmMessage("assistant", "[Đã hiển thị tour giảm giá]"));
      } else if (m is MessageBudgetTours) {
        history.add(LlmMessage("assistant", "[Đã hiển thị tour ngân sách]"));
      } else if (m is MessageDurationTours) {
        history.add(LlmMessage("assistant", "[Đã hiển thị tour số ngày]"));
      } else if (m is MessageCheapTours) {
        history.add(LlmMessage("assistant", "[Đã hiển thị tour rẻ nhất]"));
      } else if (m is MessageAiItinerary) {
        history.add(LlmMessage("assistant", "[Đã hiển thị lịch trình]"));
      } else if (m.type == MessageType.user) {
        history.add(LlmMessage("user", m.text));
      } else if (m.type == MessageType.aiText) {
        history.add(LlmMessage("assistant", m.text));
      }
    }

    final reply = await _gemini.chat(history: history);

    // 🛑 Chặn luôn meta text AI trả về để UI không hiển thị
    if (reply.trim().startsWith("[Đã hiển thị")) {
      return;
    }

    dynamic parsed;
    try {
      parsed = jsonDecode(reply);
    } catch (_) {
      parsed = null;
    }

    // =============== cheap tours ================
    if (parsed is Map && parsed["action"] == "cheap_tours") {
      final limit = parsed["limit"] ?? 5;
      final tours = await _tourSearch.searchCheapTours(limit: limit);

      setState(() => _messages.add(MessageCheapTours(tours)));
      _autoScroll();
      return;
    }

    // =============== budget search ================
    if (parsed is Map && parsed["action"] == "budget_search") {
      final maxPrice = parsed["max_price"] ?? 0;
      final tours = await _tourSearch.searchByBudget(maxPrice: maxPrice);

      setState(() => _messages.add(MessageBudgetTours(tours)));
      _autoScroll();
      return;
    }

    // =============== min budget search ================
    if (parsed is Map && parsed["action"] == "min_budget_search") {
      final min = parsed["min_price"] ?? 0;
      final tours = await _tourSearch.searchMinBudget(minPrice: min);

      setState(() => _messages.add(MessageBudgetTours(tours)));
      _autoScroll();
      return;
    }

    // =============== range budget search ================
    if (parsed is Map && parsed["action"] == "range_budget_search") {
      final min = parsed["min_price"] ?? 0;
      final max = parsed["max_price"] ?? 0;
      final tours =
          await _tourSearch.searchRangeBudget(minPrice: min, maxPrice: max);

      setState(() => _messages.add(MessageBudgetTours(tours)));
      _autoScroll();
      return;
    }

    // =============== discount search ================
    if (parsed is Map && parsed["action"] == "search_tours") {
      final keyword = parsed["keyword"] ?? "";
      final minDiscount = parsed["min_discount"] ?? 0;
      final tours = await _tourSearch.searchDiscountTours(
        keyword: keyword,
        minDiscount: minDiscount,
      );

      setState(() => _messages.add(MessageDiscountTours(tours)));
      _autoScroll();
      return;
    }

    // =============== itinerary ================
    if (parsed is Map && parsed["action"] == "itinerary_query") {
      final name = parsed["tour_name"] ?? "";
      final items = await ItineraryService().getItinerary(name);

      setState(() {
        _messages.add(Message.aiText("📌 Lịch trình tour \"$name\":"));
        _messages.add(MessageAiItinerary(items));
      });

      _autoScroll();
      return;
    }

    // =============== duration search ================
    if (parsed is Map && parsed["action"] == "duration_search") {
      final days = parsed["days"] ?? 0;
      final tours = await _tourSearch.searchByDuration(days);

      setState(() => _messages.add(MessageDurationTours(tours)));
      _autoScroll();
      return;
    }

    // =============== DEFAULT TEXT ================
    setState(() {
      // Không render rác hoặc meta
      if (reply.trim().isNotEmpty && !reply.trim().startsWith("[Đã hiển thị")) {
        _messages.add(Message.aiText(reply));
      }
    });
    _autoScroll();
  }

  // ============================================================
  // UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 390;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("AI Chat"),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];

                if (msg is MessageDiscountTours) {
                  return _buildDiscountTours(msg.tours, scale);
                }
                if (msg is MessageBudgetTours) {
                  return _buildBudgetTours(msg.tours, scale);
                }
                if (msg is MessageDurationTours) {
                  return _buildDurationTours(msg.tours, scale);
                }
                if (msg is MessageCheapTours) {
                  return _buildCheapTours(msg.tours, scale);
                }
                if (msg is MessageAiItinerary) {
                  return _buildItineraryBlock(msg.items, scale);
                }

                // Chặn message AI rỗng
                if (msg.type == MessageType.aiText && msg.text.trim().isEmpty) {
                  return const SizedBox.shrink();
                }

                return msg.type == MessageType.user
                    ? _bubbleUser(msg.text)
                    : _bubbleAi(msg.text);
              },
            ),
          ),
          _inputBar(scale),
        ],
      ),
    );
  }

  // ============================================================
  // BUBBLES
  // ============================================================
  Widget _bubbleUser(String text) => Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue[200],
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(text),
        ),
      );

  Widget _bubbleAi(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(text),
        ),
      );

  // ============================================================
  // CARD RENDER
  // ============================================================
  Widget _buildDiscountTours(List<Map<String, dynamic>> tours, double scale) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("🔻 Tour đang giảm giá:", style: TextStyle(fontSize: 15)),
          const SizedBox(height: 8),
          ...tours.map((t) {
            return GestureDetector(
              onTap: () async {
                final id = t['tour_id'];
                final list = await _tourSearch.getFullTours([id]);
                if (list.isEmpty) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(tour: list.first),
                  ),
                );
              },
              child: DiscountTourCard(tour: t, scale: scale),
            );
          }),
        ],
      );

  Widget _buildBudgetTours(List<Map<String, dynamic>> tours, double scale) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("💰 Tour theo ngân sách:", style: TextStyle(fontSize: 15)),
          const SizedBox(height: 8),
          ...tours.map((t) {
            return GestureDetector(
              onTap: () async {
                final id = t['tour_id'];
                final list = await _tourSearch.getFullTours([id]);
                if (list.isEmpty) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(tour: list.first),
                  ),
                );
              },
              child: BudgetTourCard(tour: t, scale: scale),
            );
          }),
        ],
      );

  Widget _buildDurationTours(List<Map<String, dynamic>> tours, double scale) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("📅 Tour theo số ngày:", style: TextStyle(fontSize: 15)),
          const SizedBox(height: 8),
          ...tours.map((t) {
            return GestureDetector(
              onTap: () async {
                final id = t['tour_id'];
                final list = await _tourSearch.getFullTours([id]);
                if (list.isEmpty) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(tour: list.first),
                  ),
                );
              },
              child: DurationTourCard(tour: t, scale: scale),
            );
          }),
        ],
      );

  Widget _buildCheapTours(List<Map<String, dynamic>> tours, double scale) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("💸 Top tour rẻ nhất:", style: TextStyle(fontSize: 15)),
          const SizedBox(height: 8),
          ...tours.map((t) {
            return GestureDetector(
              onTap: () async {
                final id = t['tour_id'];
                final list = await _tourSearch.getFullTours([id]);
                if (list.isEmpty) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(tour: list.first),
                  ),
                );
              },
              child: CheapTourCard(tour: t, scale: scale),
            );
          }),
        ],
      );

  // ============================================================
  // ITINERARY UI
  // ============================================================
  Widget _buildItineraryBlock(List<Map<String, dynamic>> items, double scale) {
    final grouped = <int, List<Map<String, dynamic>>>{};

    for (final it in items) {
      final day = it["day_number"] ?? 1;
      grouped.putIfAbsent(day, () => []);
      grouped[day]!.add(it);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((e) {
        final day = e.key;
        final acts = e.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "📅 Ngày $day",
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 6),
              ...acts.map((a) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F7FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            a["image_url"],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a["activity_name"],
                                style: GoogleFonts.lato(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${a["start_time"]} - ${a["end_time"]}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ))
            ],
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // INPUT BAR
  // ============================================================
  Widget _inputBar(double scale) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Hỏi tour, lịch trình, giá rẻ...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _send,
            child: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
