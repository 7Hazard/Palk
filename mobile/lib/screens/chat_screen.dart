import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/models/chat.dart';
import 'package:flutter_chat_ui/models/chat_entry.dart';
import 'package:flutter_chat_ui/models/profile.dart';
import 'package:intl/intl.dart';

import 'chat_settings.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  ChatScreen(this.chat);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var dateFormatter = new DateFormat('yyyy-MM-dd');
  List<ChatEntry>? _messages;

  Future<List<ChatEntry>> get messages async {
    if (_messages != null) return _messages!;
    _messages = await widget.chat.entries;
    _messages!.sort((a, b) => b.time.compareTo(a.time));
    print("loaded messages");
    widget.chat.read = DateTime.now(); // TODO handle read flag better
    return _messages!;
  }

  Future onMessage(Chat chat, ChatEntry message) async {
    if (_messages != null) {
      setState(() {
        widget.chat.read = DateTime.now();
        _messages!.insert(0, message);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Chat.subscribeOnActivity(onMessage);
  }

  @override
  void dispose() {
    Chat.unsubscribeOnActivity(onMessage);
    super.dispose();
  }

  _buildMessage(ChatEntry entry) {
    final bool isMe = entry.message!.from.id == Profile.current!.id;
    final Container msg = Container(
      margin: isMe
          ? EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
              left: 80.0,
            )
          : EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
            ),
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        color: isMe ? Theme.of(context).colorScheme.secondary: Color(0xFFFFEFEE),
        borderRadius: isMe
            ? BorderRadius.only(
                topLeft: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0),
              )
            : BorderRadius.only(
                topRight: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            dateFormatter.format(entry.time),
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            entry.message!.from.nameOrDefault(),
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            entry.message!.content,
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    if (isMe) {
      return msg;
    }
    return Row(
      children: <Widget>[
        msg,
      ],
    );
  }

  _buildMessageComposer() {
    var textController = TextEditingController();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 80.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: textController,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {},
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              widget.chat.sendMessage(textController.text);
              textController.clear();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Unnamed chat", // TODO if only one participant, show his name
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {
              //open new screen here, put
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatSettings(
                          chat: widget.chat,
                        )),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  child: FutureBuilder(
                    future: messages,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<ChatEntry>> snapshot) {
                      if (snapshot.hasData) {
                        var messages = snapshot.data!;
                        return ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.only(top: 15.0),
                          itemCount: messages.length,
                          itemBuilder: (BuildContext context, int index) {
                            final ChatEntry entry = messages[index];
                            return _buildMessage(entry);
                          },
                        );
                      } else {
                        return ListView();
                      }
                    },
                  ),
                ),
              ),
            ),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }
}
