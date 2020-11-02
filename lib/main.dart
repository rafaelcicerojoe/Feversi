import 'package:flutter/material.dart';
import 'widgets/score_board.dart';
import 'widgets/board.dart';
import 'widgets/footer.dart';
import 'model/board_model.dart';
import 'model/misc.dart';
import 'constants/constants.dart';
import 'utils/utils.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Reversi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: createMaterialColor(Color(GameConfig.primaryColor)),
        accentColor: Colors.green,
      ),
      home: MyHomePage(title: 'Flutter Reversi'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BoardModel _board;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _board = BoardModel(boardSize: GameConfig.boardSize);
  }

  void _onTapCell(BoardCoordinates pos) {
    setState(() {
      if (_board.currentStone == StoneType.white) return;
      if (_board.putStone(pos, _board.boardMap) == true) {
        _board.proceedIA();
      }
    });
  }

  void _onSkip() {
    setState(() {
      _board.skipTurn();
    });
  }

  void _onRestart() {
    setState(() {
      _initGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_board.isValid()) return Scaffold();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          children: [
            ScoreBoard(
                whiteCount: _board.whiteCount, blackCount: _board.blackCount),
            Expanded(
              child: Center(
                child: Board(model: _board, onTapCell: _onTapCell),
              ),
            ),
            Footer(currentStone: _board.currentStone, winner: _board.winner)
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Visibility(
              visible: _board.winner == null &&
                  _board.currentStone == StoneType.black,
              child: FloatingActionButton(
                onPressed: _onSkip,
                tooltip: 'Skip Turn',
                child: Icon(Icons.skip_next),
              ),
            ),
            Visibility(
              visible: _board.winner != null ||
                  _board.currentStone == StoneType.black,
              child: FloatingActionButton(
                onPressed: _onRestart,
                tooltip: 'Restart',
                child: Icon(Icons.refresh),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
