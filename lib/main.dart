import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const GhostMeshApp());
}

class GhostMeshApp extends StatelessWidget {
  const GhostMeshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GhostMesh P2P',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0F12),
        primaryColor: const Color(0xFF00FFCC),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFCC),
          secondary: Color(0xFFFF0055),
          surface: Color(0xFF161B22),
        ),
      ),
      home: const MeshHomeScreen(),
    );
  }
}

class MeshHomeScreen extends StatefulWidget {
  const MeshHomeScreen({super.key});

  @override
  State<MeshHomeScreen> createState() => _MeshHomeScreenState();
}

class _MeshHomeScreenState extends State<MeshHomeScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _messages = [
    {
      'sender': 'Node_Alpha [192.168.1.12]',
      'text': 'Encrypted handshake initiated. Signal strength 98%.',
      'time': '18:02',
      'isMe': false,
      'type': 'text',
      'bytesBase64': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  // Local Storage se messages load karna
  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('ghostmesh_chat_history');
    if (savedData != null) {
      final List<dynamic> decoded = jsonDecode(savedData);
      setState(() {
        _messages = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    }
  }

  // Local Storage me messages save karna
  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_messages);
    await prefs.setString('ghostmesh_chat_history', encoded);
  }

  void _sendMessage({String type = 'text', String content = '', String? bytesBase64}) {
    final textToSend = content.isNotEmpty ? content : _msgController.text.trim();
    if (textToSend.isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'You [Ghost_Node]',
        'text': textToSend,
        'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'isMe': true,
        'type': type,
        'bytesBase64': bytesBase64,
      });
      if (content.isEmpty) _msgController.clear();
    });

    _saveMessages();
  }

  Future<void> _pickRealImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        _sendMessage(
          type: 'image',
          content: image.name,
          bytesBase64: base64String,
        );
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _pickRealFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
      if (result != null && result.files.single.bytes != null) {
        final platformFile = result.files.single;
        final sizeKb = (platformFile.size / 1024).toStringAsFixed(1);
        final base64String = base64Encode(platformFile.bytes!);
        _sendMessage(
          type: 'file',
          content: '${platformFile.name} ($sizeKb KB)',
          bytesBase64: base64String,
        );
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  void _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ghostmesh_chat_history');
    setState(() {
      _messages = [
        {
          'sender': 'System',
          'text': 'Local storage wiped. Encrypted buffer cleared.',
          'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          'isMe': false,
          'type': 'text',
          'bytesBase64': null,
        }
      ];
    });
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12161F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'TRANSMIT ENCRYPTED PAYLOAD',
                style: TextStyle(
                  color: Color(0xFF00FFCC),
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _mediaTile(Icons.image, 'Real Image', () {
                    Navigator.pop(context);
                    _pickRealImage();
                  }),
                  _mediaTile(Icons.insert_drive_file, 'Real File', () {
                    Navigator.pop(context);
                    _pickRealFile();
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _mediaTile(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFF161B22),
            child: Icon(icon, color: const Color(0xFF00FFCC)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF12161F),
        title: const Text(
          'GHOSTMESH P2P',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FFCC),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Color(0xFFFF0055)),
            tooltip: 'Clear Encrypted Storage',
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] == true;
                final type = msg['type'];
                final bytesBase64 = msg['bytesBase64'];

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF00FFCC).withOpacity(0.12) : const Color(0xFF161B22),
                      border: Border.all(
                        color: isMe ? const Color(0xFF00FFCC) : const Color(0xFF2D3748),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['sender']!,
                          style: TextStyle(
                            color: isMe ? const Color(0xFF00FFCC) : const Color(0xFFFF0055),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (type == 'text')
                          Text(msg['text']!, style: const TextStyle(color: Colors.white, fontSize: 14))
                        else if (type == 'image' && bytesBase64 != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.memory(
                                  base64Decode(bytesBase64),
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(msg['text']!, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          )
                        else
                          Row(
                            children: [
                              const Icon(Icons.insert_drive_file, color: Color(0xFF00FFCC)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  msg['text']!,
                                  style: const TextStyle(color: Colors.white, fontSize: 13, decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(msg['time']!, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF12161F),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Color(0xFF00FFCC)),
                  onPressed: _showMediaPicker,
                ),
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Transmit payload...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF161B22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF00FFCC)),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFCC),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  ),
                  onPressed: () => _sendMessage(),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}