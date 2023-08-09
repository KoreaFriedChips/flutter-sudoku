import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:sudoku/my_flutter_app_icons.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';
import 'Styles.dart';
import 'Alerts.dart';
import 'SplashScreenPage.dart';
import 'my_flutter_app_icons.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'dart:core';

class BacktrackingAlgorithm {
  static List<SolutionStep> solve(List<List<int>> puzzle) {
    List<SolutionStep> solutionSteps = [];
    // print(puzzle);
    if (_solveSudoku(puzzle, solutionSteps)) {
      return solutionSteps;
    } else {
      return []; // No solution found
    }
  }

  static bool _solveSudoku(
      List<List<int>> puzzle, List<SolutionStep> solutionSteps) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (puzzle[row][col] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (_isValidMove(puzzle, row, col, num)) {
              puzzle[row][col] = num;
              solutionSteps.add(SolutionStep(row, col, num));

              if (_solveSudoku(puzzle, solutionSteps)) {
                return true; // Solution found
              }

              // Backtrack
              puzzle[row][col] = 0;
              solutionSteps.removeLast();
            }
          }

          return false; // No valid number found, backtrack
        }
      }
    }

    return true; // All cells filled, puzzle solved
  }

  static bool _isValidMove(List<List<int>> puzzle, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (puzzle[row][i] == num || puzzle[i][col] == num) {
        return false; // Number already present in row or column
      }
    }

    int startRow = row - row % 3;
    int startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (puzzle[startRow + i][startCol + j] == num) {
          return false; // Number already present in 3x3 subgrid
        }
      }
    }

    return true; // Valid move
  }
}

class SolutionStep {
  final int row;
  final int col;
  final int value;

  SolutionStep(this.row, this.col, this.value);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(MyApp());
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

class MyApp extends StatelessWidget {
  static final String versionNumber = "0.05";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Styles.primaryColor,
      ),
      home: SplashScreenPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool firstRun = true;
  bool gameOver = false;
  int timesCalled = 0;
  bool isButtonDisabled = false;
  bool hintUsed = false;
  List<List<List<int>>> gameList;
  List<List<int>> game;
  List<List<int>> gameCopy;
  List<List<int>> gameSolved;
  static String currentDifficultyLevel;
  static String currentTheme;
  static String currentAccentColor;
  static String platform;
  static int curX, curY;
  static int prvX, prvY, prvV;
  static int mistakes = 0;
  bool lose = false;
  final StopWatchTimer time = StopWatchTimer();
  static String displayTime;

  @override
  void dispose() {
    super.dispose();
    time.dispose();
  }

  @override
  void initState() {
    super.initState();
    getPrefs().whenComplete(() {
      if (currentDifficultyLevel == null) {
        currentDifficultyLevel = 'Easy';
        setPrefs('currentDifficultyLevel');
      }
      if (currentTheme == null) {
        if (MediaQuery.maybeOf(context)?.platformBrightness != null) {
          currentTheme =
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? 'light'
                  : 'dark';
        } else {
          currentTheme = 'dark';
        }
        setPrefs('currentTheme');
      }
      if (currentAccentColor == null) {
        currentAccentColor = 'Blue';
        setPrefs('currentAccentColor');
      }
      newGame(currentDifficultyLevel);
      changeTheme('set');
      changeAccentColor(currentAccentColor, true);
    });
  }

  Future<void> getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentDifficultyLevel = prefs.getString('currentDifficultyLevel');
      currentTheme = prefs.getString('currentTheme');
      currentAccentColor = prefs.getString('currentAccentColor');
    });
  }

  setPrefs(String property) async {
    final prefs = await SharedPreferences.getInstance();
    if (property == 'currentDifficultyLevel') {
      prefs.setString('currentDifficultyLevel', currentDifficultyLevel);
    } else if (property == 'currentTheme') {
      prefs.setString('currentTheme', currentTheme);
    } else if (property == 'currentAccentColor') {
      prefs.setString('currentAccentColor', currentAccentColor);
    }
  }

  void changeTheme(String mode) {
    setState(() {
      if (currentTheme == 'light') {
        if (mode == 'switch') {
          Styles.primaryBackgroundColor = Styles.darkGrey;
          Styles.secondaryBackgroundColor = Styles.grey;
          Styles.foregroundColor = Styles.white;
          currentTheme = 'dark';
        } else if (mode == 'set') {
          Styles.primaryBackgroundColor = Styles.white;
          Styles.secondaryBackgroundColor = Styles.white;
          Styles.foregroundColor = Styles.darkGrey;
        }
      } else if (currentTheme == 'dark') {
        if (mode == 'switch') {
          Styles.primaryBackgroundColor = Styles.white;
          Styles.secondaryBackgroundColor = Styles.white;
          Styles.foregroundColor = Styles.darkGrey;
          currentTheme = 'light';
        } else if (mode == 'set') {
          Styles.primaryBackgroundColor = Styles.darkGrey;
          Styles.secondaryBackgroundColor = Styles.grey;
          Styles.foregroundColor = Styles.white;
        }
      }
      setPrefs('currentTheme');
    });
  }

  void changeAccentColor(String color, [bool firstRun = false]) {
    setState(() {
      if (Styles.accentColors.keys.contains(color)) {
        Styles.primaryColor = Styles.accentColors[color];
      } else {
        currentAccentColor = 'Blue';
        Styles.primaryColor = Styles.accentColors[color];
      }
      if (color == 'Red') {
        Styles.secondaryColor = Styles.orange;
      } else {
        Styles.secondaryColor = Styles.lightRed;
      }
      if (!firstRun) {
        setPrefs('currentAccentColor');
      }
    });
  }

  void checkResult() {
    try {
      if (lose) {
        time.onExecute.add(StopWatchExecute.stop);
        isButtonDisabled = !isButtonDisabled;
        gameOver = true;
        Timer(Duration(milliseconds: 500), () {
          showAnimatedDialog<void>(
              animationType: DialogTransitionType.fadeScale,
              barrierDismissible: true,
              duration: Duration(milliseconds: 350),
              context: context,
              builder: (_) => AlertLose()).whenComplete(() {
            if (AlertLose.newGame) {
              newGame(currentDifficultyLevel);
              AlertLose.newGame = false;
            } else if (AlertLose.restartGame) {
              restartGame();
              AlertLose.restartGame = false;
            }
          });
        });
      } else if (SudokuUtilities.isSolved(game)) {
        time.onExecute.add(StopWatchExecute.stop);
        isButtonDisabled = !isButtonDisabled;
        gameOver = true;
        Timer(Duration(milliseconds: 500), () {
          showAnimatedDialog<void>(
              animationType: DialogTransitionType.fadeScale,
              barrierDismissible: true,
              duration: Duration(milliseconds: 350),
              context: context,
              builder: (_) => AlertGameOver()).whenComplete(() {
            if (AlertGameOver.newGame) {
              newGame(currentDifficultyLevel);
              AlertGameOver.newGame = false;
            } else if (AlertGameOver.restartGame) {
              restartGame();
              AlertGameOver.restartGame = false;
            }
          });
        });
      }
    } on InvalidSudokuConfigurationException {
      return;
    }
  }

  static List<List<List<int>>> getNewGame([String difficulty = 'Easy']) {
    int emptySquares;
    if (difficulty == 'test')
      emptySquares = 2;
    else if (difficulty == 'Beginner')
      emptySquares = 18;
    else if (difficulty == 'Easy')
      emptySquares = 27;
    else if (difficulty == 'Medium')
      emptySquares = 36;
    else
      emptySquares = 54;
    SudokuGenerator generator = new SudokuGenerator(emptySquares: emptySquares);
    return [generator.newSudoku, generator.newSudokuSolved];
  }

  void setGame(int mode, [String difficulty = 'Easy']) {
    time.onExecute.add(StopWatchExecute.reset);
    time.onExecute.add(StopWatchExecute.start);
    if (mode == 1) {
      game = new List.generate(9, (i) => [0, 0, 0, 0, 0, 0, 0, 0, 0]);
      gameCopy = SudokuUtilities.copySudoku(game);
      gameSolved = SudokuUtilities.copySudoku(game);
    } else {
      gameList = getNewGame(difficulty);
      game = gameList[0];
      gameCopy = SudokuUtilities.copySudoku(game);
      gameSolved = gameList[1];
    }
  }

  void showSolution() {
    setState(() {
      curX = null;
      curY = null;
      isButtonDisabled = true;
      gameOver = true;
    });
    time.onExecute.add(StopWatchExecute.stop);

    solveSudokuAnimated();
  }

  Future<void> solveSudokuAnimated() async {
    bool solved = await _animateSolveSudoku(0, 0);
    if (solved) {
      print("Sudoku puzzle solved!");
    } else {
      print("No solution found for the Sudoku puzzle.");
    }
  }

  Future<bool> _animateSolveSudoku(int row, int col) async {
    if (row == 9) {
      row = 0;
      col++;
      if (col == 9) {
        // Animation finished
        return true;
      }
    }

    if (game[row][col] != 0) {
      // Cell is already filled, move to the next cell
      return await _animateSolveSudoku(row + 1, col);
    } else {
      for (int num = 1; num <= 9; num++) {
        if (isValidMove(row, col, num)) {
          setState(() {
            game[row][col] = num; // Update the Sudoku board state
          });

          // Add an animation delay (adjust the duration as needed)
          await Future.delayed(Duration(milliseconds: 100));

          bool solved = await _animateSolveSudoku(row + 1, col);

          if (solved) {
            return true; // Puzzle solved
          }

          setState(() {
            game[row][col] = 0; // Backtrack
          });

          // Add an animation delay (adjust the duration as needed)
          await Future.delayed(Duration(milliseconds: 100));
        }
      }
    }

    return false; // No solution found
  }

  bool isValidMove(int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (game[row][i] == num || game[i][col] == num) {
        return false; // Number already present in row or column
      }
    }

    // Check if the number already exists in the same 3x3 sub-grid
    int subgridRow = (row ~/ 3) * 3;
    int subgridCol = (col ~/ 3) * 3;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (game[subgridRow + i][subgridCol + j] == num) return false;
      }
    }
    return true; // Valid move
  }

  void newGame([String difficulty = 'Easy']) {
    setState(() {
      setGame(2, difficulty);
      isButtonDisabled =
          isButtonDisabled ? !isButtonDisabled : isButtonDisabled;
      gameOver = false;
      prvV = null;
      curX = null;
      curY = null;
      mistakes = 0;
      lose = false;
      time.onExecute.add(StopWatchExecute.reset);
      time.onExecute.add(StopWatchExecute.start);
    });
  }

  void restartGame() {
    setState(() {
      game = SudokuUtilities.copySudoku(gameCopy);
      isButtonDisabled =
          isButtonDisabled ? !isButtonDisabled : isButtonDisabled;
      gameOver = false;
      hintUsed = false;
      prvV = null;
      curX = null;
      curY = null;
      mistakes = 0;
      lose = false;
      time.onExecute.add(StopWatchExecute.reset);
      time.onExecute.add(StopWatchExecute.start);
    });
  }

  Color buttonColor(int k, int i) {
    if (curX == k && curY == i) {
      return Styles.white;
    }
    Color color;
    int x, y;
    if (curX != null && curY != null) {
      x = curX - curX.remainder(3) + 1;
      y = curY - curY.remainder(3) + 1;
      if ([x - 1, x, x + 1].contains(k) && [y - 1, y, y + 1].contains(i))
        return Styles.grey[200];
    }
    if (([curX].contains(k) && [0, 1, 2, 3, 4, 5, 6, 7, 8].contains(i)) ||
        ([curY].contains(i) && [0, 1, 2, 3, 4, 5, 6, 7, 8].contains(k))) {
      color = Styles.grey[100];
    } else if (([0, 1, 2].contains(k) && [3, 4, 5].contains(i)) ||
        ([3, 4, 5].contains(k) && [0, 1, 2, 6, 7, 8].contains(i)) ||
        ([6, 7, 8].contains(k) && [3, 4, 5].contains(i))) {
      if (Styles.primaryBackgroundColor == Styles.darkGrey) {
        color = Styles.grey[300];
      } else {
        color = Colors.grey[400];
      }
    } else {
      color = Styles.primaryBackgroundColor;
    }
    return color;
  }

  BorderRadiusGeometry buttonEdgeRadius(int k, int i) {
    if (k == 0 && i == 0) {
      return BorderRadius.only(topLeft: Radius.circular(5));
    } else if (k == 0 && i == 8) {
      return BorderRadius.only(topRight: Radius.circular(5));
    } else if (k == 8 && i == 0) {
      return BorderRadius.only(bottomLeft: Radius.circular(5));
    } else if (k == 8 && i == 8) {
      return BorderRadius.only(bottomRight: Radius.circular(5));
    }
    return BorderRadius.circular(0);
  }

  List<SizedBox> createButtons() {
    if (firstRun) {
      setGame(1);
      firstRun = false;
    }
    MaterialColor emptyColor;
    if (gameOver && !lose) {
      emptyColor = Styles.primaryColor;
    } else {
      emptyColor = Styles.secondaryColor;
    }
    List<SizedBox> buttonList = new List<SizedBox>.filled(9, null);
    for (var i = 0; i <= 8; i++) {
      var k = timesCalled;
      buttonList[i] = SizedBox(
        width: 38,
        height: 38,
        child: TextButton(
          onPressed: isButtonDisabled || gameCopy[k][i] != 0
              ? null
              : () {
                  setState(() {
                    curX = k;
                    curY = i;
                  });
                },
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(buttonColor(k, i)),
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return gameCopy[k][i] == 0
                    ? emptyColor
                    : Styles.foregroundColor;
              }
              if (game[k][i] == 0) {
                return buttonColor(k, i);
              } else if (!check(k, i)) {
                HapticFeedback.vibrate();
                return Styles.secondaryColor;
              } else {
                return Styles.primaryColor;
              }
            }),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: buttonEdgeRadius(k, i),
              ),
            ),
            side: MaterialStateProperty.all<BorderSide>(
              BorderSide(
                color: Styles.foregroundColor,
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
          ),
          child: Text(
            game[k][i] != 0 ? game[k][i].toString() : ' ',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    timesCalled++;
    if (timesCalled == 9) {
      timesCalled = 0;
    }
    return buttonList;
  }

  Row oneRow() {
    return Row(
      children: createButtons(),
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  List<Row> createRows() {
    List<Row> rowList = new List<Row>.filled(9, null);
    for (var i = 0; i <= 8; i++) {
      rowList[i] = oneRow();
    }
    return rowList;
  }

  bool check(int k, int i) {
    if (gameSolved[k][i] == game[k][i])
      return true;
    else
      return false;
  }

  void callback(int x, int y, int number, bool undo) {
    setState(() {
      if (number == null || x == null || y == null) {
        return;
      } else if (number == 0) {
        prvV = game[x][y];
        game[x][y] = number;
      } else {
        prvX = x;
        prvY = y;
        prvV = game[x][y];
        game[x][y] = number;
        if (!undo) {
          if (!check(x, y)) {
            mistakes++;
            if (mistakes == 3) {
              lose = true;
            }
          }
          checkResult();
        }
      }
    });
  }

  // pencil / notes
  // work in progress, still need to think about this one.

  // ** disable after 1 use
  void hint() {
    bool flag = false;
    for (int i = 0; i <= 8; i++) {
      for (int j = 0; j <= 8; j++) {
        if (game[i][j] == 0 || game[i][j] == null) {
          setState(() {
            game[i][j] = gameSolved[i][j];
            prvX = i;
            prvY = j;
            hintUsed = true;
            checkResult();
          });
          flag = true;
          break;
        }
      }
      if (flag) break;
    }
  }

  showOptionModalSheet(BuildContext context) {
    BuildContext outerContext = context;
    showModalBottomSheet(
        context: context,
        backgroundColor: Styles.secondaryBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        builder: (context) {
          final TextStyle customStyle =
              TextStyle(inherit: false, color: Styles.foregroundColor);
          return Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.lightbulb_outline_rounded,
                    color: Styles.foregroundColor),
                title: Text('Show Solution', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(Duration(milliseconds: 200), () => showSolution());
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.build_outlined, color: Styles.foregroundColor),
                title: Text('Set Difficulty', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(
                    Duration(milliseconds: 300),
                    () => showAnimatedDialog<void>(
                            animationType: DialogTransitionType.fadeScale,
                            barrierDismissible: true,
                            duration: Duration(milliseconds: 350),
                            context: outerContext,
                            builder: (_) =>
                                AlertDifficultyState(currentDifficultyLevel))
                        .whenComplete(() {
                      if (AlertDifficultyState.difficulty != null) {
                        Timer(Duration(milliseconds: 300), () {
                          newGame(AlertDifficultyState.difficulty);
                          currentDifficultyLevel =
                              AlertDifficultyState.difficulty;
                          AlertDifficultyState.difficulty = null;
                          setPrefs('currentDifficultyLevel');
                        });
                      }
                    }),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.invert_colors_on_rounded,
                    color: Styles.foregroundColor),
                title: Text('Switch Theme', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(Duration(milliseconds: 200), () {
                    changeTheme('switch');
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.color_lens_outlined,
                    color: Styles.foregroundColor),
                title: Text('Change Accent Color', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(
                      Duration(milliseconds: 200),
                      () => showAnimatedDialog<void>(
                              animationType: DialogTransitionType.fadeScale,
                              barrierDismissible: true,
                              duration: Duration(milliseconds: 350),
                              context: outerContext,
                              builder: (_) => AlertAccentColorsState(
                                  currentAccentColor)).whenComplete(() {
                            if (AlertAccentColorsState.accentColor != null) {
                              Timer(Duration(milliseconds: 300), () {
                                currentAccentColor =
                                    AlertAccentColorsState.accentColor;
                                changeAccentColor(
                                    currentAccentColor.toString());
                                AlertAccentColorsState.accentColor = null;
                                setPrefs('currentAccentColor');
                              });
                            }
                          }));
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline_rounded,
                    color: Styles.foregroundColor),
                title: Text('About', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(
                      Duration(milliseconds: 200),
                      () => showAnimatedDialog<void>(
                          animationType: DialogTransitionType.fadeScale,
                          barrierDismissible: true,
                          duration: Duration(milliseconds: 350),
                          context: outerContext,
                          builder: (_) => AlertAbout()));
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async {
        showAnimatedDialog<void>(
            animationType: DialogTransitionType.fadeScale,
            barrierDismissible: true,
            duration: Duration(milliseconds: 350),
            context: context,
            builder: (_) => AlertExit());
        return true;
      },
      child: new Scaffold(
        backgroundColor: Styles.primaryBackgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: AppBar(
            centerTitle: true,
            title: Text('Sudoku'),
            backgroundColor: Styles.primaryColor,
          ),
        ),
        body: Builder(builder: (builder) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Timer(Duration(milliseconds: 200),
                                () => newGame(currentDifficultyLevel));
                          },
                          icon: Icon(Icons.add_rounded,
                              color: Styles.foregroundColor),
                          label: Text('New Game'),
                          style: ElevatedButton.styleFrom(
                            primary: Styles.primaryColor,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Timer(Duration(milliseconds: 200),
                                () => restartGame());
                          },
                          icon: Icon(Icons.refresh,
                              color: Styles.foregroundColor),
                          label: Text('Restart Game'),
                          style: ElevatedButton.styleFrom(
                            primary: Styles.primaryColor,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '$currentDifficultyLevel'.toCapitalized(),
                          style: TextStyle(
                            color: currentTheme == 'dark'
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        Text(
                          "Mistakes: " + '$mistakes' + "/3",
                          style: TextStyle(
                            color: currentTheme == 'dark'
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        StreamBuilder<int>(
                            stream: time.rawTime,
                            initialData: time.rawTime.value,
                            builder: (context, snap) {
                              final value = snap.data;
                              displayTime = StopWatchTimer.getDisplayTime(value,
                                  hours: false, milliSecond: false);
                              return Text(
                                displayTime,
                                style: TextStyle(
                                  color: currentTheme == 'dark'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              );
                            }),
                      ],
                    ),
                    Column(children: createRows()),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            child: Column(
                              children: [
                                Tab(
                                  icon: Icon(
                                    Icons.undo_outlined,
                                    color: Styles.primaryColor,
                                  ),
                                  child: Text(
                                    'Undo',
                                    style:
                                        TextStyle(color: Styles.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              //print(prvV);
                              callback(prvX, prvY, prvV, true);
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          TextButton(
                            child: Column(
                              children: [
                                Tab(
                                  icon: Icon(
                                    MyFlutterApp.eraser,
                                    color: Styles.primaryColor,
                                  ),
                                  child: Text(
                                    'Erase',
                                    style:
                                        TextStyle(color: Styles.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              callback(curX, curY, 0, false);
                              //print(prvV);
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          // TextButton(
                          //   child: Column(
                          //     children: [
                          //       Tab(
                          //         icon: Icon(
                          //           MyFlutterApp.pencil_neg,
                          //           color: Styles.primaryColor,
                          //         ),
                          //         child: Text(
                          //           'Notes',
                          //           style: TextStyle(color: Styles.primaryColor),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          //   style: TextButton.styleFrom(
                          //     minimumSize: Size.zero,
                          //     padding: EdgeInsets.zero,
                          //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          //   ),
                          // ),
                          TextButton(
                            child: Column(
                              children: [
                                Tab(
                                  icon: Icon(
                                    Icons.lightbulb_outline_rounded,
                                    color: Styles.primaryColor,
                                  ),
                                  child: Text(
                                    'Hint',
                                    style:
                                        TextStyle(color: Styles.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () => hintUsed ? null : hint(),
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      // create a row of buttons for 1 - 9
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            child: Text('1',
                                style: TextStyle(
                                  color: Styles.primaryColor,
                                  fontSize: 20,
                                )),
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              callback(curX, curY, 1, false);
                            },
                          ),
                          TextButton(
                            child: Text('2',
                                style: TextStyle(
                                  color: Styles.primaryColor,
                                  fontSize: 20,
                                )),
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              callback(curX, curY, 2, false);
                            },
                          ),
                          TextButton(
                            child: Text('3',
                                style: TextStyle(
                                  color: Styles.primaryColor,
                                  fontSize: 20,
                                )),
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              callback(curX, curY, 3, false);
                            },
                          ),
                          TextButton(
                            child: Text('4',
                                style: TextStyle(
                                  color: Styles.primaryColor,
                                  fontSize: 20,
                                )),
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              callback(curX, curY, 4, false);
                            },
                          ),
                          TextButton(
                            child: Text('5',
                                style: TextStyle(
                                  color: Styles.primaryColor,
                                  fontSize: 20,
                                )),
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              callback(curX, curY, 5, false);
                            },
                          ),
                          TextButton(
                            child: Text('6',
                                style: TextStyle(
                                  color: Styles.primaryColor,
                                  fontSize: 20,
                                )),
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              callback(curX, curY, 6, false);
                            },
                          ),
                          TextButton(
                            child: Text('7',
                                style: TextStyle(
                                  color: Styles.primaryColor,
                                  fontSize: 20,
                                )),
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              callback(curX, curY, 7, false);
                            },
                          ),
                          TextButton(
                            child: Text('8',
                                style: TextStyle(
                                  color: Styles.primaryColor,
                                  fontSize: 20,
                                )),
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              callback(curX, curY, 8, false);
                            },
                          ),
                          TextButton(
                            child: Text('9',
                                style: TextStyle(
                                  color: Styles.primaryColor,
                                  fontSize: 20,
                                )),
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              callback(curX, curY, 9, false);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 35,
                ),
              ],
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          foregroundColor: Styles.primaryBackgroundColor,
          backgroundColor: Styles.primaryColor,
          onPressed: () => showOptionModalSheet(context),
          child: Icon(Icons.settings_outlined),
        ),
      ),
    );
  }
}
