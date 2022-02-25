import 'package:flutter/material.dart';
import 'package:palk/models/chat.dart';
import 'package:palk/models/chat_entry.dart';
import 'package:palk/models/profile.dart';
import 'package:intl/intl.dart';

import 'chat_settings_screen.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  ChatScreen(this.chat);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var dateFormatter = new DateFormat('yyyy-MM-dd');
  List<ChatEntry>? _messages;

  /// Cached
  Future<List<ChatEntry>> get entries async {
    if (_messages != null) return _messages!;
    _messages = await widget.chat.entries;
    _messages!.sort((a, b) => b.time.compareTo(a.time));
    print("loaded messages");
    widget.chat.read = DateTime.now(); // TODO handle read flag better
    widget.chat.save();
    return _messages!;
  }

  Future onActivity(Chat chat, ChatEntry message) async {
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
    Chat.subscribeOnActivity(onActivity);
  }

  @override
  void dispose() {
    Chat.unsubscribeOnActivity(onActivity);
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
        color:
            isMe ? Theme.of(context).colorScheme.secondary : Color(0xFFFFEFEE),
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

    void sendMessage(String value) {
      value = value.trim();
      if (value.isEmpty) return;
      widget.chat.sendMessage(value);
      textController.clear();
    }

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
              onSubmitted: (value) {
                sendMessage(value);
              },
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
              sendMessage(textController.text);
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
          widget.chat.name,
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
                    builder: (context) => ChatSettings(widget.chat)),
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
                    future: entries,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<ChatEntry>> snapshot) {
                      if (snapshot.hasData) {
                        var entries = snapshot.data!;
                        return ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.only(top: 15.0),
                          itemCount: entries.length,
                          itemBuilder: (BuildContext context, int index) {
                            final ChatEntry entry = entries[index];
                            switch (entry.kind) {
                              case "message":
                                return _buildMessage(entry);
                              case "event":
                                return Center(
                                  child: Text(
                                    entry.event ?? "Error getting event",
                                  ),
                                );
                              default:
                                return Center(
                                  child: Text("Unknown kind '${entry.kind}'"),
                                );
                            }
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
