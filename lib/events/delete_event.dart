import 'dart:async';

class DeleteEventState {
  final bool isChecked;
  final bool isDeletable;
  final bool deleteNoteClicked;
  final bool deleteTodoClicked;
  final bool backBtnClose;

  const DeleteEventState({
    this.isChecked = false,
    this.isDeletable = false,
    this.deleteNoteClicked = false,
    this.deleteTodoClicked = false,
    this.backBtnClose = false,
  });

  DeleteEventState copyWith({
    bool? isChecked,
    bool? isDeletable,
    bool? deleteNoteClicked,
    bool? deleteTodoClicked,
    bool? backBtnClose,
  }) {
    return DeleteEventState(
      isChecked: isChecked ?? this.isChecked,
      isDeletable: isDeletable ?? this.isDeletable,
      deleteNoteClicked: deleteNoteClicked ?? this.deleteNoteClicked,
      deleteTodoClicked: deleteTodoClicked ?? this.deleteTodoClicked,
      backBtnClose: backBtnClose ?? this.backBtnClose,
    );
  }
}

class DeleteEventBus {
  final _controller = StreamController<DeleteEventState>.broadcast();

  DeleteEventState _state = const DeleteEventState();

  Stream<DeleteEventState> get stream => _controller.stream;
  Stream<bool> get deleteNoteClickedStream =>
      stream.map((e) => e.deleteNoteClicked).distinct();
  Stream<bool> get deleteTodoClickedStream =>
      stream.map((e) => e.deleteTodoClicked).distinct();
  Stream<bool> get backBtnClickedStream =>
      stream.map((e) => e.backBtnClose).distinct();

  void emitChecked(bool value) {
    _state = _state.copyWith(isChecked: value);
    _controller.add(_state);
  }

  void emitDeletable(bool value) {
    _state = _state.copyWith(isDeletable: value);
    _controller.add(_state);
  }

  void emitDeleteNoteClicked(bool value) {
    _state = _state.copyWith(deleteNoteClicked: value);
    _controller.add(_state);
  }

  void emitDeleteTodoClicked(bool value) {
    _state = _state.copyWith(deleteTodoClicked: value);
    _controller.add(_state);
  }

  void emitClose(bool value) {
    _state = _state.copyWith(backBtnClose: value);
    _controller.add(_state);
  }

  void dispose() {
    _controller.close();
  }
}

final deleteEventBus = DeleteEventBus();
