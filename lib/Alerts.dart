import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Styles.dart';
import 'main.dart';

class AlertGameOver extends StatelessWidget {
  static bool newGame = false;
  static bool restartGame = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Styles.secondaryBackgroundColor,
      title: Text(
        'Game Over',
        style: TextStyle(color: Styles.foregroundColor),
      ),
      content: Text(
        'You successfully solved the Sudoku',
        style: TextStyle(color: Styles.foregroundColor),
      ),
      actions: [
        TextButton(
          style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all<Color>(Styles.primaryColor)),
          onPressed: () {
            Navigator.pop(context);
            restartGame = true;
          },
          child: Text('Restart Game'),
        ),
        TextButton(
          style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all<Color>(Styles.primaryColor)),
          onPressed: () {
            Navigator.pop(context);
            newGame = true;
          },
          child: Text('New Game'),
        ),
      ],
    );
  }
}

class AlertLose extends StatelessWidget {
  static bool newGame = false;
  static bool restartGame = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Styles.secondaryBackgroundColor,
      title: Text(
        'Game Over',
        style: TextStyle(color: Styles.foregroundColor),
      ),
      content: Text(
        'You failed to solve the Sudoku',
        style: TextStyle(color: Styles.foregroundColor),
      ),
      actions: [
        TextButton(
          style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all<Color>(Styles.primaryColor)),
          onPressed: () {
            Navigator.pop(context);
            restartGame = true;
          },
          child: Text('Restart Game'),
        ),
        TextButton(
          style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all<Color>(Styles.primaryColor)),
          onPressed: () {
            Navigator.pop(context);
            newGame = true;
          },
          child: Text('New Game'),
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class AlertDifficultyState extends StatefulWidget {
  String currentDifficultyLevel;

  AlertDifficultyState(String currentDifficultyLevel) {
    this.currentDifficultyLevel = currentDifficultyLevel;
  }

  @override
  AlertDifficulty createState() => AlertDifficulty(this.currentDifficultyLevel);

  static get difficulty {
    return AlertDifficulty.difficulty;
  }

  static set difficulty(String level) {
    AlertDifficulty.difficulty = level;
  }
}

class AlertDifficulty extends State<AlertDifficultyState> {
  static String difficulty;
  static final List<String> difficulties = [
    'Beginner',
    'Easy',
    'Medium',
    'Hard'
  ];
  String currentDifficultyLevel;

  AlertDifficulty(String currentDifficultyLevel) {
    this.currentDifficultyLevel = currentDifficultyLevel;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Center(
          child: Text(
        'Select Difficulty Level',
        style: TextStyle(color: Styles.foregroundColor),
      )),
      backgroundColor: Styles.secondaryBackgroundColor,
      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      children: <Widget>[
        for (String level in difficulties)
          SimpleDialogOption(
            onPressed: () {
              if (level != this.currentDifficultyLevel) {
                setState(() {
                  difficulty = level;
                });
              }
              Navigator.pop(context);
            },
            child: Text(level[0].toUpperCase() + level.substring(1),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15,
                    color: level == this.currentDifficultyLevel
                        ? Styles.primaryColor
                        : Styles.foregroundColor)),
          ),
      ],
    );
  }
}

class AlertExit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Styles.secondaryBackgroundColor,
      title: Text(
        'Exit Game',
        style: TextStyle(color: Styles.foregroundColor),
      ),
      content: Text(
        'Are you sure you want to exit the game ?',
        style: TextStyle(color: Styles.foregroundColor),
      ),
      actions: [
        TextButton(
          style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all<Color>(Styles.primaryColor)),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('No'),
        ),
        TextButton(
          style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all<Color>(Styles.primaryColor)),
          onPressed: () {
            if (HomePageState.platform == 'android') {
              SystemNavigator.pop();
            }
          },
          child: Text('Yes'),
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class AlertAccentColorsState extends StatefulWidget {
  String currentAccentColor;

  AlertAccentColorsState(String currentAccentColor) {
    this.currentAccentColor = currentAccentColor;
  }

  static get accentColor {
    return AlertAccentColors.accentColor;
  }

  static set accentColor(String color) {
    AlertAccentColors.accentColor = color;
  }

  @override
  AlertAccentColors createState() => AlertAccentColors(this.currentAccentColor);
}

class AlertAccentColors extends State<AlertAccentColorsState> {
  static String accentColor;
  static final List<String> accentColors = [...Styles.accentColors.keys];
  String currentAccentColor;

  AlertAccentColors(String currentAccentColor) {
    this.currentAccentColor = currentAccentColor;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Center(
          child: Text(
        'Select Accent Color',
        style: TextStyle(color: Styles.foregroundColor),
      )),
      backgroundColor: Styles.secondaryBackgroundColor,
      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      children: <Widget>[
        for (String color in accentColors)
          SimpleDialogOption(
            onPressed: () {
              if (color != this.currentAccentColor) {
                setState(() {
                  accentColor = color;
                });
              }
              Navigator.pop(context);
            },
            child: Text(
              color,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: color == this.currentAccentColor
                    ? Styles.primaryColor
                    : Styles.foregroundColor,
              ),
            ),
          ),
      ],
    );
  }
}

class AlertAbout extends StatelessWidget {
  static const String authorURL = "https://www.github.com/VarunS2002/";
  static const String releasesURL =
      "https://github.com/VarunS2002/Flutter-Sudoku/releases/";
  static const String sourceURL =
      "https://github.com/VarunS2002/Flutter-Sudoku/";
  static const String licenseURL =
      "https://github.com/VarunS2002/Flutter-Sudoku/blob/master/LICENSE";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Styles.secondaryBackgroundColor,
      title: Center(
        child: Text(
          'About',
          style: TextStyle(color: Styles.foregroundColor),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icon/icon_round.png',
                  height: 48.0, width: 48.0, fit: BoxFit.contain),
              Text(
                '   Sudoku',
                style: TextStyle(
                    color: Styles.foregroundColor,
                    fontFamily: 'roboto',
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '                ',
                style: TextStyle(
                    color: Styles.foregroundColor,
                    fontFamily: 'roboto',
                    fontSize: 15),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Version: ',
                style: TextStyle(
                    color: Styles.foregroundColor,
                    fontFamily: 'roboto',
                    fontSize: 15),
              ),
              InkWell(
                onTap: () async {
                  await launch(AlertAbout.releasesURL);
                },
                child: Text(
                  MyApp.versionNumber + ' ',
                  style: TextStyle(
                      color: Styles.primaryColor,
                      fontFamily: 'roboto',
                      fontSize: 15),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '                ',
                style: TextStyle(
                    color: Styles.foregroundColor,
                    fontFamily: 'roboto',
                    fontSize: 15),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Author: ',
                style: TextStyle(
                    color: Styles.foregroundColor,
                    fontFamily: 'roboto',
                    fontSize: 15),
              ),
              InkWell(
                onTap: () async {
                  await launch(AlertAbout.authorURL);
                },
                child: Text(
                  'Alex Xu & Edison Qu',
                  style: TextStyle(
                      color: Styles.primaryColor,
                      fontFamily: 'roboto',
                      fontSize: 15),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '                ',
                style: TextStyle(
                    color: Styles.foregroundColor,
                    fontFamily: 'roboto',
                    fontSize: 15),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  await launch(AlertAbout.sourceURL);
                },
                child: Text(
                  'Source Code',
                  style: TextStyle(
                      color: Styles.primaryColor,
                      fontFamily: 'roboto',
                      fontSize: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
