// lib/screen/message_page.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:record/record.dart'; // For audio recording
import 'package:path_provider/path_provider.dart'; // To get temp directory

import '../widget/chat_widget.dart';
import '../widget/message_app_bar.dart';


class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // For audio recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  // For file picking
  File? _pickedFile;
  String? _pickedFileName;
  String? _pickedFileType;

 @override
  void initState() {
    super.initState();
    // To update the send/mic icon when text is entered/cleared
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  // Generic message sender for text, picked files, and recorded audio
  void _sendMessage({String? text, File? file, String? fileType, String? fileName}) async {
    final messageText = text ?? _controller.text.trim();
    final messageFile = file ?? _pickedFile;
    final messageFileType = fileType ?? _pickedFileType;
    final messageFileName = fileName ?? _pickedFileName;

    if (messageText.isEmpty && messageFile == null) return;

    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to send messages.")),
      );
      return;
    }

    String? fileUrl;

    // 1. Upload file if it exists
    if (messageFile != null) {
      try {
        final uniqueFileName = const Uuid().v4();
        // Use a different folder for audio messages for better organization
        final String storageFolder = (messageFileType == 'audio') ? 'audio_messages' : 'message_files';
        final ref = _storage.ref().child(storageFolder).child(uniqueFileName);
        final uploadTask = ref.putFile(messageFile);
        final snapshot = await uploadTask.whenComplete(() => {});
        fileUrl = await snapshot.ref.getDownloadURL();

        // If it was a recorded file, delete it from local temp storage after upload
        if (messageFileType == 'audio') {
          await messageFile.delete();
        }

      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("File upload failed: \$e")));
        return;
      }
    }
//aaaa
    // 2. Add message to Firestore
    await _firestore.collection('messages').add({
      "text": messageText.isNotEmpty ? messageText : null,
      "fileUrl": fileUrl,
      "fileType": messageFileType,
      "fileName": messageFileName,
      "senderId": currentUser.uid,
      "timestamp": FieldValue.serverTimestamp(),
    });

    // 3. Reset UI only if it was a standard text/file message from the input bar
    if (file == null) {
      setState(() {
        _controller.clear();
        _pickedFile = null;
        _pickedFileName = null;
        _pickedFileType = null;
      });
    }
    _scrollToBottom();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final name = result.files.single.name;
      final ext = name.split('.').last.toLowerCase();

      String type = "file";
      if (['jpg','jpeg','png','gif'].contains(ext)) type = "image";
      else if (['mp4','mov'].contains(ext)) type = "video";

      setState(() {
        _pickedFile = File(path);
        _pickedFileName = name;
        _pickedFileType = type;
      });
    }
  }

  Future<void> _startRecording() async {
    // Note: You must add microphone permission to your AndroidManifest.xml
    // e.g., <uses-permission android:name="android.permission.RECORD_AUDIO" />
    try {
      if (await _audioRecorder.hasPermission()) {
          final Directory tempDir = await getTemporaryDirectory();
          final String path = '\${tempDir.path}/\${const Uuid().v4()}.m4a';

          await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
          setState(() { _isRecording = true; });
      }
    } catch (e) {
       if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Recording failed to start: \$e")));
    }
  }

  Future<void> _stopAndSendRecording() async {
    try {
      final String? path = await _audioRecorder.stop();
      setState(() { _isRecording = false; });

      if (path == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Recording failed.")));
        return;
      }

      final recordedFile = File(path);
      if (await recordedFile.exists()) {
        _sendMessage(file: recordedFile, fileType: 'audio', fileName: 'Voice Message');
      }
    } catch (e) {
       if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to send recording: \$e")));
      setState(() { _isRecording = false; });
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final n = timestamp.toDate();
    final h = n.hour > 12 ? n.hour - 12 : (n.hour == 0 ? 12 : n.hour);
    return "\$h:\${n.minute.toString().padLeft(2,'0')} \${n.hour >= 12 ? 'PM' : 'AM'}";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5),
      appBar: MessageAppBar(
        imageUrl: 'https://i.postimg.cc/rsKBpFHp/b2e1202f1a945c1d46ee9e3d6c58b970.gif',
        title: 'Habib',
        isActive: true,
        subtitle: 'Active now',
        onAudioCall: () {},
        onVideoCall: () {},
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').orderBy('timestamp', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong."));
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                     _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (_, i) {
                    final messageDoc = snapshot.data!.docs[i];
                    final messageData = messageDoc.data() as Map<String, dynamic>;
                    final bool isMe = currentUser != null && messageData['senderId'] == currentUser.uid;

                    return ChatWidget(
                      text: messageData["text"],
                      fileUrl: messageData["fileUrl"],
                      fileType: messageData["fileType"],
                      fileName: messageData["fileName"],
                      isMe: isMe,
                      time: _formatTimestamp(messageData["timestamp"] as Timestamp?),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_pickedFile != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.attachment, size: 20, color: Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_pickedFileName ?? 'File', overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87),)),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              _pickedFile = null;
                              _pickedFileName = null;
                              _pickedFileType = null;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.emoji_emotions_outlined), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.attach_file), onPressed: _pickFile),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: _isRecording ? "Recording..." : "Type a message...",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (_controller.text.trim().isNotEmpty || _pickedFile != null) {
                          _sendMessage();
                        }
                      },
                      onLongPressStart: (_) {
                        if (_controller.text.trim().isEmpty && _pickedFile == null) {
                          _startRecording();
                        }
                      },
                      onLongPressEnd: (_) {
                        if (_isRecording) {
                          _stopAndSendRecording();
                        }
                      },
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.teal,
                        child: Icon(
                           _isRecording 
                            ? Icons.stop 
                            : (_controller.text.trim().isNotEmpty || _pickedFile != null) 
                              ? Icons.send 
                              : Icons.mic,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 84), // This might be for the custom nav bar, leaving it.
        ],
      ),
    );
  }
}
