import 'package:flutter/material.dart';

/// A form field optimized for time (hh:mm)
class TimeField extends StatefulWidget {
  final TimeFieldController controller;

  /// Creats a form field optimized for time (hh:mm). A [TimeFieldController]
  /// `controller` can be used to get or set the value and listen to changes
  const TimeField({Key key, @required this.controller}) : super(key: key);
  @override
  _TimeFieldState createState() => _TimeFieldState();
}

class _TimeFieldState extends State<TimeField> {
  final _hourController = TextEditingController();
  final _minuteController = TextEditingController();
  final _hourFocusNode = FocusNode();
  final _minuteFocusNode = FocusNode();
  final _fieldTextStyle = TextStyle(fontSize: 25);

  @override
  void initState() {
    super.initState();

    if (widget.controller != null && widget.controller.value != null) {
      _hourController.text = widget.controller.value.hour.toString();
      _minuteController.text = widget.controller.value.minute.toString();
    } else {
      final now = TimeOfDay.now();
      _hourController.text = now.hour.toString();
      _minuteController.text = now.minute.toString();
    }

    _finalizeHourField();
    _finalizeMinuteField();
    _validateFields();

    _hourController.addListener(() {
      _cleanHourField();
      _validateFields();

      if (_hourController.text.length == 2) {
        _minuteFocusNode.requestFocus();
      }
    });

    _minuteController.addListener(() {
      _cleanMinuteField();
      _validateFields();
    });

    _hourFocusNode.addListener(() {
      if (_hourFocusNode.hasFocus) {
        _hourFieldGetFocus();
      } else {
        _finalizeHourField();
      }
    });

    _minuteFocusNode.addListener(() {
      if (_minuteFocusNode.hasFocus) {
        _minuteFieldGetFocus();
      } else {
        _finalizeMinuteField();
      }
    });
  }

  void _cleanHourField() {
    var text = _hourController.text;
    if (text.length > 2) {
      text = text.substring(0, 2);
    }

    text = text.replaceAll(RegExp(r"[^0-9]"), "");

    if (text.length == 2) {
      if (int.tryParse(text.characters.elementAt(0)) > 2 ||
          (int.tryParse(text.characters.elementAt(0)) == 2 &&
              int.tryParse(text.characters.elementAt(1)) > 3)) {
        text = text.substring(0, 1);
      }
    }

    if (text != _hourController.text) {
      _hourController.value = TextEditingValue(
          text: text, selection: TextSelection.collapsed(offset: text.length));
    }
  }

  void _finalizeHourField() {
    _cleanHourField();

    if (_hourController.text.length == 1) {
      _hourController.text = '0${_hourController.text}';
    }
  }

  void _finalizeMinuteField() {
    _cleanMinuteField();

    if (_minuteController.text.length == 1) {
      _minuteController.text = '0${_minuteController.text}';
    }
  }

  void _cleanMinuteField() {
    var text = _minuteController.text;
    if (text.length > 2) {
      text = text.substring(0, 2);
    }

    text = text.replaceAll(RegExp(r"[^0-9]"), "");

    if (text.length == 2) {
      if (int.tryParse(text.characters.elementAt(0)) > 5) {
        text = text.substring(0, 1);
      }
    }

    if (text != _minuteController.text) {
      _minuteController.value = TextEditingValue(
          text: text, selection: TextSelection.collapsed(offset: text.length));
    }
  }

  void _hourFieldGetFocus() {
    _hourController.selection =
        TextSelection(baseOffset: 0, extentOffset: _hourController.text.length);
    _hourFocusNode.requestFocus();
  }

  void _minuteFieldGetFocus() {
    _minuteController.selection = TextSelection(
        baseOffset: 0, extentOffset: _minuteController.text.length);
    _minuteFocusNode.requestFocus();
  }

  void _validateFields() {
    if (_hourController.text.length > 0 &&
        int.tryParse(_hourController.text) != null &&
        _minuteController.text.length > 0 &&
        int.tryParse(_minuteController.text) != null) {
      widget.controller.value = TimeOfDay(
        hour: int.tryParse(_hourController.text),
        minute: int.tryParse(_minuteController.text),
      );
    } else {
      widget.controller.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          child: TextField(
            controller: _hourController,
            focusNode: _hourFocusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: _fieldTextStyle,
            decoration: InputDecoration(hintText: '00'),
          ),
        ),
        Text(
          ':',
          style: TextStyle(
              fontSize: 25, color: Theme.of(context).textTheme.caption.color),
        ),
        SizedBox(
          width: 40,
          child: TextField(
            controller: _minuteController,
            focusNode: _minuteFocusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: _fieldTextStyle,
            decoration: InputDecoration(hintText: '00'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }
}

/// A controller that can be used in combination with a TimeField to get or set
/// its value and listen to changes
class TimeFieldController extends ValueNotifier<TimeOfDay> {
  /// Creates a controller that can be used in combination with a TimeField to
  /// get or set its value and listen to changes. An `initialTime` for the field
  /// can be provided.
  TimeFieldController({TimeOfDay initialTime}) : super(initialTime);
}
