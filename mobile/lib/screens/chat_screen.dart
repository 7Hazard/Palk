import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/models/chat.dart';
import 'package:flutter_chat_ui/models/message.dart';

import 'chat_settings.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  ChatScreen({this.chat});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  _buildMessage(Message message, bool isMe) {
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
        color: isMe ? Theme.of(context).accentColor : Color(0xFFFFEFEE),
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
            message.time.toString(),
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            message.text,
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
              Message.send(textController.text, widget.chat.id, widget.chat.key);
              textController.clear();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Chat.onMessage.remove(widget.chat.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Message> messages;
    Chat.onMessage[widget.chat.id] = (message) {
      messages.add(message);
      setState(() {});
    };

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
                MaterialPageRoute(builder: (context) => ChatSettings(chat: widget.chat,)),
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
                    future: Message.getAll(widget.chat.id),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Message>> snapshot) {
                      if (snapshot.hasData) {
                        messages = snapshot.data;
                        return ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.only(top: 15.0),
                          itemCount: messages.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Message message = messages[index];
                            final bool isMe = message.sender.id == currentUser.id;
                            return _buildMessage(message, isMe);
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
