part of dash_chat;

class ChatInputToolbar extends StatelessWidget {
  final TextEditingController controller;
  final TextStyle inputTextStyle;
  final InputDecoration inputDecoration;
  final BoxDecoration inputContainerStyle;
  final List<Widget> leading;
  final List<Widget> trailling;
  final int inputMaxLines;
  final int maxInputLength;
  final bool alwaysShowSend;
  final ChatUser user;
  final Function(ChatMessage) onSend;
  final String text;
  final Function(String) onTextChange;
  final String Function() messageIdGenerator;
  final Widget Function(Function) sendButtonBuilder;
  final Widget Function() inputFooterBuilder;
  final bool showInputCursor;
  final double inputCursorWidth;
  final Color inputCursorColor;
  final ScrollController scrollController;
  final bool showTraillingBeforeSend;
  final FocusNode focusNode;
  final EdgeInsets inputToolbarPadding;
  final EdgeInsets inputToolbarMargin;

  ChatInputToolbar({
    Key key,
    this.focusNode,
    this.scrollController,
    this.text,
    this.onTextChange,
    this.controller,
    this.leading = const [],
    this.trailling = const [],
    this.inputDecoration,
    this.inputTextStyle,
    this.inputContainerStyle,
    this.inputMaxLines = 1,
    this.showInputCursor = true,
    this.maxInputLength,
    this.inputCursorWidth = 2.0,
    this.inputCursorColor,
    this.onSend,
    @required this.user,
    this.alwaysShowSend = false,
    this.messageIdGenerator,
    this.inputFooterBuilder,
    this.sendButtonBuilder,
    this.showTraillingBeforeSend = true,
    this.inputToolbarPadding = const EdgeInsets.all(0.0),
    this.inputToolbarMargin = const EdgeInsets.all(0.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ChatMessage message = ChatMessage(
      text: text,
      user: user,
      messageIdGenerator: messageIdGenerator,
      createdAt: DateTime.now(),
    );

    return SafeArea(
      child: Container(
        padding: inputToolbarPadding,
        margin: inputToolbarMargin,
        decoration: inputContainerStyle != null ? inputContainerStyle : BoxDecoration(color: Colors.transparent),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ...leading,
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          height: 64,
                          color: Colors.white,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6.0, left: 8, right: 4),
                              child: TextField(
                                focusNode: focusNode,
                                onChanged: (value) {
                                  onTextChange(value);
                                  SchedulerBinding.instance.addPostFrameCallback((_) {
                                    scrollController.jumpTo(scrollController.position.maxScrollExtent - 10);
                                  });
                                },
                                buildCounter: (
                                  BuildContext context, {
                                  int currentLength,
                                  int maxLength,
                                  bool isFocused,
                                }) =>
                                    null,
                                decoration: inputDecoration != null
                                    ? inputDecoration
                                    : InputDecoration.collapsed(
                                        hintText: "",
                                        fillColor: Colors.white,
                                      ),
                                controller: controller,
                                style: inputTextStyle,
//                                onSubmitted: (text) async {
//                                  //FocusScope.of(context).unfocus();
//                                  focusNode.unfocus();
//
//                                  await onSend(message);
//
//                                  controller.text = "";
//
//                                  //Timer(Duration(milliseconds: 700), () {
//                                  Timer(Duration(milliseconds: 700), () {
//                                    scrollController.animateTo(
//                                      scrollController.position.maxScrollExtent + 38,
//                                      curve: Curves.easeOut,
//                                      duration: const Duration(milliseconds: 500),
//                                    );
//                                  });
//                                },
                                textInputAction: TextInputAction.newline,
                                maxLength: maxInputLength,
                                minLines: 1,
                                maxLines: inputMaxLines,
                                showCursor: showInputCursor,
                                cursorColor: inputCursorColor,
                                cursorWidth: inputCursorWidth,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showTraillingBeforeSend) ...trailling,
                    sendButtonBuilder(() async {
                      if (controller.text != '') await onSend(message);

                      //focusNode.unfocus();
                      controller.text = "";

//                      SchedulerBinding.instance.addPostFrameCallback((_) {
//                        scrollController.animateTo(
//                          scrollController.position.maxScrollExtent,
//                          curve: Curves.easeOut,
//                          duration: const Duration(milliseconds: 500),
//                        );
//                      });

                      Timer(Duration(milliseconds: 500), () {
                        scrollController.animateTo(
                          scrollController.position.maxScrollExtent - 10,
                          curve: Curves.easeOut,
                          duration: const Duration(milliseconds: 300),
                        );
                      });
                    }),
                    if (!showTraillingBeforeSend) ...trailling,
                  ],
                ),
              ),
            ),
            if (inputFooterBuilder != null) inputFooterBuilder()
          ],
        ),
      ),
    );
  }
}
