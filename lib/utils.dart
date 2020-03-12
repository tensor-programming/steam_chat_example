import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:provider/provider.dart';

import 'package:chat_stream/model.dart';

class CustomForm extends StatelessWidget {
  final String hintText;
  final GlobalKey formKey;
  final TextEditingController controller;

  const CustomForm({
    Key key,
    this.hintText,
    this.formKey,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: hintText,
        ),
        validator: (input) {
          if (input.isEmpty) {
            return "Enter some Text";
          }
          if (input.contains(RegExp(r"^([A-Za-z0-9]){4,20}$"))) {
            return null;
          }
          return "Can not contain special characters or spaces.";
        },
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const CustomButton({
    Key key,
    this.onPressed,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.blueGrey,
        elevation: 6.0,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 45.0,
          child: Text(text),
        ),
      ),
    );
  }
}

List<Widget> createListOfChannels(List<Channel> channels, context) {
  final provider = Provider.of<ChatModel>(context);

  return channels
      // convert to list to gain access to the index and make deletion more reliable.
      .asMap()
      .map((idx, chan) => MapEntry(
          idx,
          ListTile(
            // unique key makes it easier for the streamview to know which ListTile is which.
            key: UniqueKey(),
            title: Text(
              "Channel Title: ${chan.cid.replaceFirstMapped("mobile:", (match) => "")}",
            ),
            subtitle: Text("Last Message at: ${chan.lastMessageAt}"),
            trailing: Text("Peers: ${chan.state.members.length}"),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                  chan.extraData["image"] ?? "https://picsum.photos/100/100"),
            ),
            onLongPress: () async {
              // remove channel from list.
              channels.removeAt(idx);
              provider.currentChannel = chan;
              await chan.delete();
            },
          )))
      .values
      .toList();
}
