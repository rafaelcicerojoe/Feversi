import '../model/misc.dart';
import '../constants/constants.dart';

List<List<StoneType>> getNewBoard(size) {
  if (size < 3) return null;
  final start = (size / 2).floor() - 1;
  final end = size % 2 == 0 ? start + 1 : start + 2;
  return List.generate(
    size,
    (x) => List.generate(size, (y) {
      if (x < start || x > end || y < start || y > end) return StoneType.empty;
      return (x + y) % 2 == 1 ? StoneType.black : StoneType.white;
    }),
  );
}

class BoardModel {
  int _size;
  StoneType _currentStone;
  List<List<StoneType>> _boardMap;

  BoardModel({int boardSize})
      : _size = boardSize,
        _currentStone = StoneType.black,
        _boardMap = getNewBoard(boardSize);

  int get size => _size;

  StoneType get currentStone => _currentStone;

  StoneType getAt(BoardCoordinates pos) => _boardMap[pos.x][pos.y];

  StoneType setAt(BoardCoordinates pos, StoneType type) =>
      _boardMap[pos.x][pos.y] = type;

  int get blackCount {
    List<StoneType> allStones = _boardMap.expand((column) => column).toList();
    return allStones.where((stone) => stone == StoneType.black).length;
  }

  int get whiteCount {
    List<StoneType> allStones = _boardMap.expand((column) => column).toList();
    return allStones.where((stone) => stone == StoneType.white).length;
  }

  List<List<StoneType>> get boardMap {
    return _boardMap;
  }

  bool get isGameOver =>
      whiteCount + blackCount == _size * _size ||
      whiteCount + blackCount == whiteCount ||
      whiteCount + blackCount == blackCount;

  StoneType get winner {
    if (!isGameOver) return null;
    if (blackCount > whiteCount || whiteCount + blackCount == blackCount)
      return StoneType.black;
    if (blackCount < whiteCount || whiteCount + blackCount == whiteCount)
      return StoneType.white;
    return StoneType.empty;
  }

  List<BoardCoordinates> _getFlipsByVector(
      BoardCoordinates pos, BoardVector vector) {
    final result = List<BoardCoordinates>();
    int currentX = pos.x, currentY = pos.y;

    void advance() {
      currentX += vector.deltaX;
      currentY += vector.deltaY;
    }

    advance();
    while (currentX > -1 &&
        currentX < _size &&
        currentY > -1 &&
        currentY < _size) {
      StoneType thisStone = _boardMap[currentX][currentY];
      if (thisStone == _currentStone) {
        return result;
      } else if (thisStone == StoneType.empty) {
        return [];
      } else {
        result.add(BoardCoordinates(currentX, currentY));
        advance();
      }
    }
    return [];
  }

  List<BoardCoordinates> _validMoves([bool inverted = false]) {
    final List<BoardCoordinates> validPos = [];
    _boardMap.asMap().forEach((i, line) {
      line.asMap().forEach((j, cell) {
        final pos = BoardCoordinates(i, j);
        if (getAt(pos) != StoneType.empty) return;

        final flipList = List<BoardCoordinates>();
        FLIP_VECTOR_LIST.forEach((vector) {
          if (inverted == true) {
            _flipCurrentStone();
            flipList.addAll(_getFlipsByVector(pos, vector));
            _flipCurrentStone();
          } else {
            flipList.addAll(_getFlipsByVector(pos, vector));
          }
        });
        if (flipList.isEmpty == false) {
          validPos.add(pos);
        }
      });
    });
    return validPos;
  }

  void _flipStones(
      List<BoardCoordinates> coordinates, List<List<StoneType>> boardMap) {
    coordinates.forEach((pos) => boardMap[pos.x][pos.y] = _currentStone);
  }

  void _flipCurrentStone() {
    if (_currentStone == StoneType.black)
      _currentStone = StoneType.white;
    else
      _currentStone = StoneType.black;
  }

  bool putStone(BoardCoordinates pos, List<List<StoneType>> boardMap,
      [bool skip = true]) {
    if (getAt(pos) != StoneType.empty) return false;

    final flipList = List<BoardCoordinates>();
    FLIP_VECTOR_LIST.forEach((vector) {
      flipList.addAll(_getFlipsByVector(pos, vector));
    });

    if (flipList.isEmpty == true) return false;
    flipList.add(pos);

    _flipStones(flipList, boardMap);
    if (skip) {
      _flipCurrentStone();
    }
    return true;
  }

  bool isOnCorner(x, y) {
    return (x == 0 && y == 0) ||
        (x == 7 && y == 0) ||
        (x == 0 && y == 7) ||
        (x == 7 && y == 7);
  }

  int currentWhiteCount(List<List<StoneType>> boardMap) {
    List<StoneType> allStones = boardMap.expand((column) => column).toList();
    return allStones.where((stone) => stone == StoneType.white).length;
  }

  int currentBlackCount(List<List<StoneType>> boardMap) {
    List<StoneType> allStones = boardMap.expand((column) => column).toList();
    return allStones.where((stone) => stone == StoneType.black).length;
  }

  void proceedIA() {
    final possibleMoves = _validMoves();
    print(possibleMoves.length);
    if (possibleMoves.length == 0) {
      skipTurn();
      return;
    }

    BoardCoordinates bestMove;
    int simScore = whiteCount - blackCount;

    int bestScore = -500;

    possibleMoves.forEach((pos) {
      List<List<StoneType>> boardCopied =
          new List<List<StoneType>>.from(_boardMap.map((value) {
        return new List<StoneType>.from(value);
      }));

      int playerScore = proceedPlayer(boardCopied);

      putStone(pos, boardCopied, false);

      if (playerScore == -500) {
        simScore =
            currentWhiteCount(boardCopied) - currentBlackCount(boardCopied);
      } else {
        simScore = currentWhiteCount(boardCopied) -
            currentBlackCount(boardCopied) -
            playerScore;
      }

      if (simScore > bestScore) {
        bestScore = simScore;
        bestMove = pos;
      }
    });

    putStone(bestMove, _boardMap);
  }

  int proceedPlayer(List<List<StoneType>> boardMap) {
    final possibleMoves = _validMoves(true);

    if (possibleMoves.length == 0) {
      return -500;
    }

    int score = whiteCount - blackCount;

    int bestScore = -500;

    possibleMoves.forEach((pos) {
      List<List<StoneType>> boardCopied =
          new List<List<StoneType>>.from(boardMap.map((value) {
        return new List<StoneType>.from(value);
      }));

      putStone(pos, boardCopied, false);

      score = currentWhiteCount(boardCopied) - currentBlackCount(boardCopied);

      if (score > bestScore) {
        bestScore = score;
      }
    });

    return bestScore;
  }

  void skipTurn() {
    _flipCurrentStone();
    if (_currentStone == StoneType.white) proceedIA();
  }

  bool isValid() => _boardMap != null;
}
