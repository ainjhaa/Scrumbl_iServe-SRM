// widgets/ai_chat_popup.dart - Updated Version
import 'package:demo_app/services/ai_services.dart';
import 'package:flutter/material.dart';

class AIChatPopup extends StatefulWidget {
  const AIChatPopup({super.key});

  @override
  State<AIChatPopup> createState() => _AIChatPopupState();
}

class _AIChatPopupState extends State<AIChatPopup> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize AI service when chat opens
    _initializeAIService();
  }

  Future<void> _initializeAIService() async {
    print('🧠 Initializing AI Service from chat popup...');
    try {
      await AIService.initialize();
      print('✅ AI Service initialized successfully');
    } catch (e) {
      print('❌ AI Service initialization failed: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI Service: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // In ai_chat_popup.dart
  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
  
    final userMessage = _controller.text.trim();
    _controller.clear();
  
    // Add user message
    setState(() {
      _messages.add({
        "sender": "user",
        "text": userMessage,
        "timestamp": DateTime.now()
      });
      _isLoading = true;
    });

    try {
      print('📤 Sending message to AI...');
      final aiResponse = await AIService.sendMessage(userMessage);
      print('🎉 AI Response received');
    
      setState(() {
        _messages.add({
          "sender": "ai",
          "text": aiResponse,
          "timestamp": DateTime.now()
        });
        _isLoading = false;
      });
    } catch (e) {
      print('💥 Error in _sendMessage: $e');
    
      // Use fallback response
      final fallback = _getFallbackResponse(userMessage);
    
      setState(() {
        _messages.add({
          "sender": "ai",
          "text": fallback,
          "timestamp": DateTime.now(),
          "isFallback": true
        });
        _isLoading = false;
      });
    }
  }

  String _getFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();
  
    if (lowerMessage.contains('rakan bumi')) {
      return "Rakan Bumi is the environmental sustainability program in Rakan Muda. It focuses on activities related to nature conservation, climate change awareness, and supporting Sustainable Development Goals (SDGs). Participants engage in tree planting, recycling initiatives, and environmental education campaigns.";
    } else if (lowerMessage.contains('rakan niaga')) {
      return "Rakan Niaga is the entrepreneurship and business program that provides training, capacity building, and innovation support to help youth develop business skills and improve their economic opportunities.";
    } else if (lowerMessage.contains('rakan prihatin')) {
      return "Rakan Prihatin focuses on community service and volunteering, building empathy and compassion through cross-generational community activities.";
    } else if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return "Hello! Welcome to Rakan Muda AI Assistant. I'm here to help you with information about our programs and activities.";
    } else {
      return "I understand you're asking about Rakan Muda. I'm currently having trouble connecting to the AI service, but here's what I can tell you based on your question: ${message.contains('?') ? 'Please check our official website or contact SRM UTM JB for detailed information.' : ''}";
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message["sender"] == "user";
    final isError = message["isError"] == true;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isError
              ? Colors.red[100]
              : isUser 
                ? Colors.blue[100] 
                : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: isError ? Border.all(color: Colors.red) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isUser ? Colors.blue : Colors.grey,
                  child: Icon(
                    isUser ? Icons.person : Icons.smart_toy,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isUser ? "You" : "Rakan AI",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isError ? Colors.red : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message["text"],
              style: TextStyle(
                fontSize: 15,
                color: isError ? Colors.red[800] : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message["timestamp"]),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.smart_toy, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text(
                        "Rakan Muda AI Assistant",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("About AI Assistant"),
                          content: const Text(
                            "This AI helps you with Rakan Muda programs, events, "
                            "and platform features. It can answer questions about "
                            "membership, activities, and general inquiries.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Chat messages
            Expanded(
              child: _messages.isEmpty && !_isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.smart_toy,
                            size: 60,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Ask me about Rakan Muda programs,\nmembership, or upcoming events!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.all(8),
                      reverse: false,
                      itemCount: _messages.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _messages.length) {
                          return _buildMessageBubble(_messages[index]);
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 12),
                                  Text("Thinking..."),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
            ),
            
            // Input area
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Ask about Rakan Muda...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => _controller.clear(),
                              )
                            : null,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
