library number_pagination;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PaginationPicking extends StatefulWidget {
  /// Creates a NumberPagination widget.
  const PaginationPicking({
    super.key,
    required this.onPageChanged,
    required this.pageTotal,
    this.threshold = 10,
    this.pageInit = 1,
    this.colorPrimary = Colors.black,
    this.colorSub = Colors.white,
    this.controlButton,
    this.iconToFirst,
    this.iconPrevious,
    this.iconNext,
    this.iconToLast,
    this.fontSize = 15,
    this.fontFamily,
  });

  ///Trigger when page changed
  final Function(int) onPageChanged;

  ///End of numbers.
  final int pageTotal;

  ///Page number to be displayed first
  final int pageInit;

  ///Numbers to show at once.
  final int threshold;

  ///Color of numbers.
  final Color colorPrimary;

  ///Color of background.
  final Color colorSub;

  ///to First, to Previous, to next, to Last Button UI.
  final Widget? controlButton;

  ///The icon of button to first.
  final Widget? iconToFirst;

  ///The icon of button to previous.
  final Widget? iconPrevious;

  ///The icon of button to next.
  final Widget? iconNext;

  ///The icon of button to last.
  final Widget? iconToLast;

  ///The size of numbers.
  final double fontSize;

  ///The fontFamily of numbers.
  final String? fontFamily;

  @override
  _PaginationPickingState createState() => _PaginationPickingState();
}

class _PaginationPickingState extends State<PaginationPicking> {
  late int rangeStart;
  late int rangeEnd;
  late int currentPage;
  late final Widget iconToFirst;
  late final Widget iconPrevious;
  late final Widget iconNext;
  late final Widget iconToLast;

  @override
  void initState() {
    currentPage = widget.pageInit;
    iconToFirst = widget.iconToFirst ?? const Icon(Icons.first_page);
    iconPrevious = widget.iconPrevious ?? const Icon(Icons.keyboard_arrow_left);
    iconNext = widget.iconNext ?? const Icon(Icons.keyboard_arrow_right);
    iconToLast = widget.iconToLast ?? const Icon(Icons.last_page);

    _rangeSet();

    super.initState();
  }

  Widget _defaultControlButton(Widget icon) {
    return AbsorbPointer(
      child: TextButton(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all<double>(5.0),
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
          minimumSize: MaterialStateProperty.all(const Size(48, 48)),
          foregroundColor: MaterialStateProperty.all(widget.colorPrimary),
          backgroundColor: MaterialStateProperty.all(widget.colorSub),
        ),
        onPressed: () {},
        child: icon,
      ),
    );
  }

  void _changePage(int page) {
    //print("Pager page: $page");
    if (page <= 0) page = 1;

    if (page > widget.pageTotal) page = widget.pageTotal;

    setState(() {
      currentPage = page;
      _rangeSet();
      widget.onPageChanged(currentPage);
    });
  }

  void _rangeSet() {
    //if (currentPage == 0) currentPage = 1;

    rangeStart = currentPage % widget.threshold == 0 ? currentPage - widget.threshold : (currentPage ~/ widget.threshold) * widget.threshold;

    rangeEnd = rangeStart + widget.threshold;
    // if (kDebugMode) {
    //   print(
    //     "currentPage ~/ widget.threshold: ${currentPage ~/ widget.threshold} - ${widget.threshold} - ${(currentPage ~/ widget.threshold) * widget.threshold}");
    //   print("rangeStart: $rangeStart - rangeEnd: $rangeEnd");
    // }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> numbertext = [];

    for (var i = 1; i <= rangeEnd; i++) {
      //print("Currentpage i: ${currentPage} - $i ");

      numbertext.add(InkWell(
        onTap: () => _changePage(i),
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: currentPage == i ? widget.colorPrimary : widget.colorSub,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
          ),
          child: Text(
            '$i',
            style: TextStyle(
              fontSize: widget.fontSize,
              fontFamily: widget.fontFamily,
              color: currentPage == i ? widget.colorSub : widget.colorPrimary,
            ),
          ),
        ),
      ));
    }
    var range = rangeEnd <= widget.pageTotal ? widget.threshold : widget.pageTotal % widget.threshold;
    // if (kDebugMode) {
    //   print("Range: $range");
    // }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /*InkWell(
            onTap: () => _changePage(0),
            child: Stack(
              children: [
                if (widget.controlButton != null) ...[
                  widget.controlButton!,
                  iconToFirst
                ] else
                  _defaultControlButton(iconToFirst),
              ],
            ),
          ),*/
          const SizedBox(
            width: 4,
          ),
          InkWell(
            onTap: () => _changePage(--currentPage),
            child: Stack(
              children: [
                if (widget.controlButton != null) ...[widget.controlButton!, iconPrevious] else _defaultControlButton(iconPrevious),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          //for (var i in numbertext) i,
          ...List.generate(
            rangeEnd <= widget.pageTotal ? widget.threshold : widget.pageTotal % widget.threshold,
            (index) => Flexible(
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  // if (kDebugMode) {
                  //   print("pager index: $index");
                  // }
                  _changePage(index + 1 + rangeStart); // _changePage(index + 1 + rangeStart);
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  decoration: BoxDecoration(
                    color: (currentPage - 1) % widget.threshold == index ? widget.colorPrimary : widget.colorSub,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Text(
                    '${index + 1 + rangeStart}', //'${index + 1 + rangeStart}',
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      fontFamily: widget.fontFamily,
                      color: (currentPage - 1) % widget.threshold == index ? widget.colorSub : widget.colorPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () => _changePage(++currentPage), //_changePage(++currentPage),
            child: Stack(
              children: [
                if (widget.controlButton != null) ...[widget.controlButton!, iconNext] else _defaultControlButton(iconNext),
              ],
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          /*InkWell(
            onTap: () => _changePage(widget.pageTotal),
            child: Stack(
              children: [
                if (widget.controlButton != null) ...[
                  widget.controlButton!,
                  iconToLast
                ] else
                  _defaultControlButton(iconToLast),
              ],
            ),
          ),*/
        ],
      ),
    );
  }
}
