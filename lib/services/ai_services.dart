// services/ai_service.dart - HYBRID SYSTEM
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = 'AIzaSyC_b7Hc78eiCACWaQXy6CoMZrANQiK18ig';
  static bool _isInitialized = false;
  
  /// Local knowledge base for SRM UTM JB specific information
  static final Map<String, String> _localKnowledge = {
    // SRM Leadership
    'president srm utm jb': 'The president of SRM UTM JB is Syahmi Khairuddin bin Mohd Fauzi.',
    'vice president srm utm jb': 'The vice president of SRM UTM JB is Azfar Fahmi bin Zulkarnain.',
    'deputy vice president management srm utm jb': 'The deputy vice president of management at SRM UTM JB is Ahmad Danish Mukhlis bin Mohd Yusof.',
    'deputy vice president activity srm utm jb': 'The deputy vice president of activity at SRM UTM JB is Nuratikah binti Ahmad.',
    'general secretary srm utm jb': 'The general secretary of SRM UTM JB is Adelia Ain binti A Matusin.',
    'work secretary srm utm jb': 'The work secretary of SRM UTM JB is Nurin Naqibah binti Mohd Fathli.',
    'honorary treasurer srm utm jb': 'The honorary treasurer of SRM UTM JB is Wan Nor Alia Atasa binti Anuar.',
    'management treasurer srm utm jb': 'The management treasurer of SRM UTM JB is Abdurrafiq bin Zakaria.',
    
    // Membership questions
    'apply membership': 'You can apply for Membership by clicking on the "Join Membership" button on the homepage, then make the payment for the registration fee. We will notify you once your Membership Application is approved.',
    
    // Program participation
    'join program': 'To join a program: 1. Go to the Activities page 2. Choose the upcoming program 3. Make payment 4. Submit payment receipt.',
    
    // Activity Badge
    'activity badge': 'Activity Badge is a feature that tracks your participation across 10 Rakan Muda lifestyle categories, displaying earned badges.',
    
    // General Rakan Muda info
    
    'gaya hidup rakan muda': 'Gaya Hidup Rakan Muda includes 10 lifestyle categories: Rakan Aktif, Rakan Bumi, Rakan Demokrasi, Rakan Digital, Rakan Ekspresi, Rakan Litar, Rakan Mahir, Rakan Muzik, Rakan Niaga and Rakan Prihatin.',
    'rakan muda': 'Rakan Muda is a youth development program by the Malaysian Ministry of Youth and Sports (KBS) implemented at SRM UTM JB.',
    'what is rakan muda': 'Rakan Muda is a comprehensive youth program focusing on environment, business, community service, democracy, and sports.',
    
    // Rakan Muda programs
    'rakan bumi': 'Rakan Bumi is the platform for exposing and exploring the importance of environmental and climate sustainability in support of the Sustainable Development Goals (SDGs)',
    'rakan niaga': 'Rakan Niaga is the platform that focuses on business and entrepreneurial activities through training, capacity building and innovation in an effort to boost the economy.',
    'rakan prihatin': 'Rakan Prihatin is the platform to instill sympathy and empathy through the cultivation of volunteering and community values (intergenerational).',
    'rakan demokrasi': 'Rakan Demokrasi is the democratic education platform which based on an understanding of the principles of the Rukun Negara and the Federal Constitution to produce young people who are democratically literate.',
    'rakan aktif': 'Rakan Aktif is the platform that focuses on physical activity to create an active and fit society in line with the aspirations of an Active Malaysia.',
    'rakan mahir': 'Rakan Mahir is the formal and non-formal education platform in the field of technical and vocational skills.',
    'rakan muzik': 'Rakan Muzik is the platform to showcase talent through skills in playing musical instruments, composing music, writing lyrics, singing and performing arts.',
    'rakan litar': 'Rakan Litar is the platform that focuses on motorized and wheeled sports activities to support healthy activities, build competitiveness and a competitive level.',
    'rakan ekspresi': 'Rakan Ekspresi is the platform to express talents, interests and ideas through oral, written and creative works based on moral, spiritual, etiquette and code of conduct.',
    'rakan digital': 'Rakan Digital is the digital technology platforms, social media and digital channels to highlight creativity and innovation and educate to become responsible consumers.',
    
    // Greetings
    'hello': 'Hello! Welcome to Rakan Muda SRM UTM JB. How can I help you today?',
    'hi': 'Hi there! I\'m your Rakan Muda assistant. What would you like to know?',
    'good morning': 'Good morning! Welcome to Rakan Muda SRM UTM JB.',
    'good afternoon': 'Good afternoon! How can I assist you with Rakan Muda programs?',
    'good evening': 'Good evening! I\'m here to help with Rakan Muda information.',

    // Additional FAQ
    'registration fee': 'The membership registration fee amount can be found on the membership application page.',
    'payment method': 'We accept various payment methods including online banking and e-wallets.',
    'contact srm': 'You can contact SRM UTM JB through our official social media or visit our office.',
    'office hours': 'SRM UTM JB office hours are typically Monday to Friday, 9 AM to 5 PM.',
    'upcoming events': 'Check the Activities page for the latest upcoming programs and events.',
  
    // Membership benefits
    'membership benefits': 'Members enjoy exclusive access to programs, activity badges, community events, and networking opportunities.',
    'benefits of membership': 'Membership provides priority registration for programs, digital badges, and community recognition.',
  };
  
  /// Initialize the AI service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('🧠 AI Service: Initializing hybrid system...');
    print('   Local knowledge base: ${_localKnowledge.length} entries');
    
    _isInitialized = true;
  }
  
  /// Send message - Hybrid approach
  static Future<String> sendMessage(String message) async {
    print('🤖 Processing: "${message.trim()}"');
    
    if (!_isInitialized) await initialize();
    
    // Step 1: Check local knowledge base first
    final localResponse = _checkLocalKnowledge(message);
    if (localResponse != null) {
      print('✅ Found in local knowledge base');
      return localResponse;
    }
    
    // Step 2: If not found locally, try Gemini AI
    print('🔍 Not found locally, trying Gemini AI...');
    return await _tryGeminiAI(message);
  }
  
  /// Check if question exists in local knowledge base
  static String? _checkLocalKnowledge(String message) {
    final lowerMessage = message.toLowerCase().trim();
    
    /* Direct key match
    if (_localKnowledge.containsKey(lowerMessage)) {
      return _localKnowledge[lowerMessage];
    }*/
    
    /* Pattern matching for common questions
    for (final key in _localKnowledge.keys) {
      if (_matchesQuestion(lowerMessage, key)) {
        return _localKnowledge[key];
      }
    }*/
    
    // Specific pattern matches
    // LEADERSHIP OF SRM UTM JB
    if ((lowerMessage.contains('deputy vice president management') || lowerMessage.contains('vice president management')) && 
        (lowerMessage.contains('srm') || lowerMessage.contains('utm') || lowerMessage.contains('jb'))) {
      return _localKnowledge['deputy vice president management srm utm jb'];
    }
    if ((lowerMessage.contains('deputy vice president activity') || lowerMessage.contains('vice president activity')) && 
        (lowerMessage.contains('srm') || lowerMessage.contains('utm') || lowerMessage.contains('jb'))) {
      return _localKnowledge['deputy vice president activity srm utm jb'];
    }
    if ((lowerMessage.contains('general secretary') || lowerMessage.contains('secretary')) && 
        (lowerMessage.contains('srm') || lowerMessage.contains('utm') || lowerMessage.contains('jb'))) {
      return _localKnowledge['general secretary srm utm jb'];
    }
    if ((lowerMessage.contains('work secretary') || lowerMessage.contains('vice secretary')) && 
        (lowerMessage.contains('srm') || lowerMessage.contains('utm') || lowerMessage.contains('jb'))) {
      return _localKnowledge['work secretary srm utm jb'];
    }
    if (lowerMessage.contains('management treasurer') && 
        (lowerMessage.contains('srm') || lowerMessage.contains('utm') || lowerMessage.contains('jb'))) {
      return _localKnowledge['management treasurer srm utm jb'];
    }
    if ((lowerMessage.contains('honorary treasurer') || lowerMessage.contains('treasurer')) && 
        (lowerMessage.contains('srm') || lowerMessage.contains('utm') || lowerMessage.contains('jb'))) {
      return _localKnowledge['honorary treasurer srm utm jb'];
    }
    if (lowerMessage.contains('vice president') && 
        (lowerMessage.contains('srm') || lowerMessage.contains('utm') || lowerMessage.contains('jb'))) {
      return _localKnowledge['vice president srm utm jb'];
    }
    if (lowerMessage.contains('president') && 
        (lowerMessage.contains('srm') || lowerMessage.contains('utm') || lowerMessage.contains('jb'))) {
      return _localKnowledge['president srm utm jb'];
    }

    // ABOUT THE APP
    if ((lowerMessage.contains('apply') || lowerMessage.contains('join') || lowerMessage.contains('how')) && 
        lowerMessage.contains('membership')) {
      return _localKnowledge['apply membership'];
    }
    if ((lowerMessage.contains('join') || lowerMessage.contains('participate') || lowerMessage.contains('how')) && 
        lowerMessage.contains('program')) {
      return _localKnowledge['join program'];
    }
    if (lowerMessage.contains('activity') && lowerMessage.contains('badge')) {
      return _localKnowledge['activity badge'];
    }
    
    // 10 GAYA HIDUP RAKAN MUDA
    if (lowerMessage.contains('gaya hidup')) {
      return _localKnowledge['gaya hidup rakan muda'];
    }
    if (lowerMessage.contains('rakan bumi')) {
      return _localKnowledge['rakan bumi'];
    }
    if (lowerMessage.contains('rakan niaga')) {
      return _localKnowledge['rakan niaga'];
    }
    if (lowerMessage.contains('rakan prihatin')) {
      return _localKnowledge['rakan prihatin'];
    }
    if (lowerMessage.contains('rakan demokrasi')) {
      return _localKnowledge['rakan demokrasi'];
    }
    if (lowerMessage.contains('rakan aktif')) {
      return _localKnowledge['rakan aktif'];
    }
    if (lowerMessage.contains('rakan mahir')) {
      return _localKnowledge['rakan mahir'];
    }
    if (lowerMessage.contains('rakan muzik')) {
      return _localKnowledge['rakan muzik'];
    }
    if (lowerMessage.contains('rakan litar')) {
      return _localKnowledge['rakan litar'];
    }
    if (lowerMessage.contains('rakan ekspresi')) {
      return _localKnowledge['rakan ekspresi'];
    }
    if (lowerMessage.contains('rakan digital')) {
      return _localKnowledge['rakan digital'];
    }
    
    return null;
  }
  
  /// Check if message matches a knowledge base key
  static bool _matchesQuestion(String message, String key) {
    final words = message.split(' ');
    final keyWords = key.split(' ');
    
    // Check if all key words appear in the message
    int matches = 0;
    for (final keyWord in keyWords) {
      if (message.contains(keyWord)) {
        matches++;
      }
    }
    
    // If at least 50% of key words match
    return matches >= (keyWords.length / 2).ceil();
  }
  
  /// Try Gemini AI as fallback
  static Future<String> _tryGeminiAI(String message) async {
    // Try different models
    final modelsToTry = [
      'gemini-1.5-flash',
      'gemini-1.5-pro',
      'gemini-2.5-pro',
      'gemini-2.5-flash',
    ];
    
    for (final model in modelsToTry) {
      print('🔄 Trying Gemini model: $model');
      
      try {
        final result = await _sendToGemini(model, message);
        
        if (result != null && result.isNotEmpty) {
          print('✅ Gemini responded with model: $model');
          return result;
        }
      } catch (e) {
        print('❌ Model $model failed: $e');
        continue;
      }
    }
    
    // If all AI models fail, use generic fallback
    print('⚠️ All AI models failed');
    return _getGenericFallback(message);
  }
  
  /// Send message to Gemini API
  static Future<String?> _sendToGemini(String model, String message) async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/$model:generateContent?key=$_apiKey'
      );
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': '''
              You are a helpful assistant for Rakan Muda SRM UTM JB, a youth community platform.
              If you don't know specific details about SRM leadership or procedures, 
              politely direct users to contact SRM administration.
              
              Question: $message
              
              Provide a helpful, concise response.
              '''
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 300,
          }
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        try {
          return data['candidates'][0]['content']['parts'][0]['text'] as String;
        } catch (e) {
          return null;
        }
      }
    } catch (e) {
      print('   💥 Gemini error: $e');
    }
    
    return null;
  }
  
  // Generic fallback for unknown questions
  static String _getGenericFallback(String message) {
    final lower = message.toLowerCase();
    
    if (lower.contains('thank') || lower.contains('thanks')) {
      return 'You\'re welcome! Is there anything else I can help you with regarding Rakan Muda?';
    }
    
    if (lower.contains('bye') || lower.contains('goodbye')) {
      return 'Goodbye! Feel free to ask if you have more questions about Rakan Muda.';
    }
    
    return '''
I understand you're asking about "$message". 
For specific information about SRM UTM JB leadership, membership, or programs, 
please check our official resources or contact the SRM administration office directly.

Here are some things I can help with:
- SRM UTM JB leadership information
- Membership application process
- Program participation guidelines
- Rakan Muda program details
''';
  }
}
