part of dash_chat;

class MessageListView extends StatefulWidget {
  final List<ChatMessage>? messages;
  final ChatUser? user;
  final bool? showuserAvatar;
  final DateFormat? dateFormat;
  final DateFormat? timeFormat;
  final bool? showAvatarForEverMessage;
  final Function(ChatUser)? onPressAvatar;
  final Function(ChatUser)? onLongPressAvatar;
  final bool? renderAvatarOnTop;
  final Function(ChatMessage, BuildContext)? onLongPressMessage;
  final bool? inverted;
  final Widget Function(ChatUser)? avatarBuilder;
  final Widget Function(ChatMessage)? messageBuilder;
  final Widget Function(String)? messageTextBuilder;
  final Widget Function(String url)? messageImageBuilder;
  final Widget Function(String)? messageTimeBuilder;
  final Widget Function(String)? dateBuilder;
  final Widget Function()? renderMessageFooter;
  final BoxDecoration? messageContainerDecoration;
  final List<MatchText> parsePatterns;
  final ScrollController? scrollController;
  final EdgeInsets messageContainerPadding;
  final Function? changeVisible;
  final bool? visible;
  final bool? showLoadMore;
  final bool? shouldShowLoadEarlier;
  final Widget Function()? showLoadEarlierWidget;
  final Function? onLoadEarlier;
  final Function(bool)? defaultLoadCallback;

  late Map<DateTime, List<String?>> _chatMessagesByDate;

  MessageListView({
    this.showLoadEarlierWidget,
    this.shouldShowLoadEarlier,
    this.onLoadEarlier,
    this.defaultLoadCallback,
    this.messageContainerPadding = const EdgeInsets.only(top: 10.0, right: 10.0, left: 10.0),
    this.scrollController,
    this.parsePatterns = const [],
    this.messageContainerDecoration,
    this.messages,
    this.user,
    this.showuserAvatar,
    this.dateFormat,
    this.timeFormat,
    this.showAvatarForEverMessage,
    this.inverted,
    this.onLongPressAvatar,
    this.onLongPressMessage,
    this.onPressAvatar,
    this.renderAvatarOnTop,
    this.messageBuilder,
    this.renderMessageFooter,
    this.avatarBuilder,
    this.dateBuilder,
    this.messageImageBuilder,
    this.messageTextBuilder,
    this.messageTimeBuilder,
    this.changeVisible,
    this.visible,
    this.showLoadMore,
  }) {
    _chatMessagesByDate = Map();
    for (ChatMessage msg in this.messages!) {
      DateTime date = DateTime(msg.createdAt!.year, msg.createdAt!.year, msg.createdAt!.day);
      if (_chatMessagesByDate[date] == null)
        _chatMessagesByDate[date] = [msg.id];
      else
        _chatMessagesByDate[date]!.add(msg.id);
    }
  }

  @override
  _MessageListViewState createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  double previousPixelPostion = 0.0;

  bool scrollNotificationFunc(ScrollNotification scrollNotification) {
    if (previousPixelPostion == 0.0) {
      previousPixelPostion = scrollNotification.metrics.maxScrollExtent;
    }

    if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent) {
      if (widget.visible!) {
        widget.changeVisible!(false);
      }
    } else {
      if (previousPixelPostion < scrollNotification.metrics.pixels) {
        if (!widget.visible!) {
          widget.changeVisible!(true);
        }
      }

      previousPixelPostion = scrollNotification.metrics.pixels;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentDate;

    return Flexible(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Padding(
          padding: widget.messageContainerPadding,
          child: NotificationListener<ScrollNotification>(
            onNotification: scrollNotificationFunc,
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: [
                ListView.builder(
                  controller: widget.scrollController,
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  //padding: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.only(bottom: 10),
                  reverse: widget.inverted!,
                  itemCount: widget.messages!.length,
                  itemBuilder: (context, i) {
//                    final j = i + 1;
//                    bool showAvatar = false;
                    bool showDate = false;
//                    if (j < widget.messages.length) {
//                      showAvatar = widget.messages[j].user.uid != widget.messages[i].user.uid;
//                    } else {
//                      showAvatar = true;
//                    }

                    var ids = widget._chatMessagesByDate[DateTime(widget.messages![i].createdAt!.year,
                            widget.messages![i].createdAt!.year, widget.messages![i].createdAt!.day)] ??
                        [];
                    if ((ids.first ?? '') == widget.messages![i].id) showDate = true;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (showDate)
                          if (widget.dateBuilder != null)
                            widget.dateBuilder!(widget.dateBuilder != null
                                ? widget.dateFormat!.format(widget.messages![i].createdAt!)
                                : DateFormat('yyyy-MM-dd').format(widget.messages![i].createdAt!))
                          else
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey, borderRadius: BorderRadius.circular(10.0)),
                              padding: EdgeInsets.only(
                                bottom: 5.0,
                                top: 5.0,
                                left: 10.0,
                                right: 10.0,
                              ),
                              margin: EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(
                                widget.dateBuilder != null
                                    ? widget.dateFormat!.format(widget.messages![i].createdAt!)
                                    : DateFormat('MMM dd').format(widget.messages![i].createdAt!),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                        GestureDetector(
                          onLongPress: () {
                            if (widget.onLongPressMessage == null) return;

                            widget.onLongPressMessage!(widget.messages![i], context);
//                            if (widget.onLongPressMessage != null) {
//                              widget.onLongPressMessage(widget.messages[i]);
//                            } else {
//                            showBottomSheet(
//                                context: context,
//                                builder: (context) => Container(
//                                      child: Column(
//                                        mainAxisSize: MainAxisSize.min,
//                                        children: <Widget>[
//                                          ListTile(
//                                            leading: Icon(Icons.delete),
//                                            title: Text("Delete Message"), // TODO move to localization
//                                            onTap: () {
//                                              //Clipboard.setData(ClipboardData(text: widget.messages[i].text));
//                                              widget.onLongPressMessage(widget.messages[i]);
//                                              Navigator.pop(context);
//                                            },
//                                          ),
//                                          ListTile(
//                                            leading: Icon(Icons.cancel),
//                                            title: Text("Cancel"), // TODO move to localization
//                                            onTap: () {
//                                              //Clipboard.setData(ClipboardData(text: widget.messages[i].text));
//                                              if (widget.onLongPressMessage != null) {
//                                                widget.onLongPressMessage(widget.messages[i]);
//                                              }
//                                              Navigator.pop(context);
//                                            },
//                                          )
//                                        ],
//                                      ),
//                                    ));
                            // }
                          },
                          child: widget.messageBuilder != null
                              ? widget.messageBuilder!(widget.messages![i])
                              : MessageContainer(
                                  isUser: widget.messages![i].user!.uid == widget.user!.uid,
                                  message: widget.messages![i],
                                  timeFormat: widget.timeFormat,
                                  messageImageBuilder: widget.messageImageBuilder,
                                  messageTextBuilder: widget.messageTextBuilder,
                                  messageTimeBuilder: widget.messageTimeBuilder,
                                  messageContainerDecoration: widget.messageContainerDecoration,
                                  parsePatterns: widget.parsePatterns,
                                ),
                        ),
                      ],
                    );
                  },
                ),
//                AnimatedPositioned(
//                  top: widget.showLoadMore ? 8.0 : -50.0,
//                  duration: Duration(milliseconds: 200),
//                  child: widget.showLoadEarlierWidget != null
//                      ? widget.showLoadEarlierWidget()
//                      : LoadEarlierWidget(
//                          onLoadEarlier: widget.onLoadEarlier,
//                          defaultLoadCallback: widget.defaultLoadCallback,
//                        ),
//                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
