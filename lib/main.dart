import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CalculatorState(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Calculator(),
          ),
        ),
      ),
    );
  }
}

class Calculator extends StatelessWidget {
  const Calculator({super.key});

  @override
  Widget build(BuildContext context) {
    var calculatorState = context.watch<CalculatorState>();

    String? result = calculatorState.result;
    String input = calculatorState.input;

    const double fontSize = 24;

    return Column(children: [
      //*--Input
      Flexible(
        flex: 1,
        fit: FlexFit.tight,
        child: Container(
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.blue, width: 2))),
          child: Row(children: [
            Flexible(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: double.maxFinite,
                  child: Text(
                    input,
                    style: const TextStyle(fontSize: fontSize),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  calculatorState.compute();
                },
                child: Container(
                  color: Colors.blue,
                  child: const Align(
                    alignment: Alignment.center,
                    child: Text(
                      '=',
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: fontSize),
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 3,
              child: Container(
                color: Colors.blueAccent[100],
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    result ?? '',
                    style: const TextStyle(fontSize: fontSize),
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
      //*--Buttons
      Flexible(
        flex: 10,
        fit: FlexFit.tight,
        child: Container(
          padding: const EdgeInsets.fromLTRB(60, 0, 60, 60),
          color: Colors.grey[350],
          child: Column(children: [
            Flexible(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex: 1,
                        child: DeleteButton(
                          fullClear: true,
                          icon: Icons.cancel_rounded,
                        ),
                      ),
                      // Spacer(),
                      Flexible(
                        flex: 1,
                        child: DeleteButton(
                          fullClear: false,
                          icon: Icons.arrow_back,
                        ),
                      ),
                    ]),
              ),
            ),
            Flexible(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                child: const Column(children: [
                  Flexible(
                    child: Row(children: [
                      CalculatorButton(text: "7"),
                      CalculatorButton(text: "8"),
                      CalculatorButton(text: "9"),
                      CalculatorButton(text: "+", computeButton: true),
                    ]),
                  ),
                  Flexible(
                    child: Row(children: [
                      CalculatorButton(text: "4"),
                      CalculatorButton(text: "5"),
                      CalculatorButton(text: "6"),
                      CalculatorButton(text: "-", computeButton: true),
                    ]),
                  ),
                  Flexible(
                    child: Row(children: [
                      CalculatorButton(text: "1"),
                      CalculatorButton(text: "2"),
                      CalculatorButton(text: "3"),
                      CalculatorButton(text: "*", computeButton: true),
                    ]),
                  ),
                  Flexible(
                    child: Row(children: [
                      CalculatorButton(text: ""),
                      CalculatorButton(text: "0"),
                      CalculatorButton(text: ""),
                      CalculatorButton(text: "/", computeButton: true)
                    ]),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }
}

class CalculatorState extends ChangeNotifier {
  String input = "";

  String? result;

  final inputController = TextEditingController();

  void inputChange(String changedInput) {
    input = changedInput;
    notifyListeners();
  }

  void inputClear() {
    input = "";
    notifyListeners();
  }

  void inputAppend(String appendPart) {
    input += appendPart;
    notifyListeners();
  }

  void inputReplaceLast(String replace) {
    input = input.substring(0, input.length - 1) + replace;
    notifyListeners();
  }

  //* Main Function that is used when user presses "=" button
  void compute() {
    //* copy calculator input value to new collection
    var temp = input;

    //* nothing happens if input is empty
    if (temp.isEmpty) {
      return;
    }

    //* if 2+2+ => takes 2+2
    if (input[input.length - 1].contains(RegExp(r'[-+*\/]+'))) {
      temp = input.substring(0, input.length - 1);
    }

    var numbers = RegExp(r'\d+')
        .allMatches(temp)
        .map((match) => num.tryParse(match[0]!))
        .toList();
    var computes =
        RegExp(r'[-+*\/]+').allMatches(temp).map((m) => m[0]).toList();

    _computeType('/', computes, numbers);
    _computeType('*', computes, numbers);
    _computeType('-', computes, numbers);
    _computeType('+', computes, numbers);

    result = numbers[0]?.toStringAsFixed(2);
    notifyListeners();
  }

  //* Subfunctions, used in "_computeType" function
  num _substrack(num a, num b) {
    return a - b;
  }

  num _multiply(num a, num b) {
    return a * b;
  }

  num _sum(num a, num b) {
    return a + b;
  }

  num _divide(num a, num b) {
    return a / b;
  }

  //* Absctract function for computing,
  //* type - what type of computing e.g. '/', '*', '-', '+'
  //* computes - collection of all computes, taken from input
  //* numbers - collection of numbers, taken from input
  void _computeType(String type, List<String?> computes, List<num?> numbers) {
    int computeIndex = type == '/'
        ? 3
        : type == '*'
            ? 2
            : type == '-'
                ? 1
                : 0;
    List<String> computesCopy = List.from(computes);
    computes.removeWhere((el) => el == type);
    List<Function> computeOptions = [_sum, _substrack, _multiply, _divide];

    while (true) {
      int curIndex = -1;

      for (var i = 0; i <= computesCopy.length - 1; i++) {
        var curType = computesCopy[i];

        if (curType == type) {
          computesCopy = computesCopy.sublist(i + 1);
          curIndex = i;
          break;
        }
      }

      if (curIndex.isNegative) {
        break;
      }

      num computedNum = computeOptions[computeIndex](
          numbers[curIndex], numbers[curIndex + 1]);

      numbers.replaceRange(curIndex, curIndex + 2, [computedNum]);
    }
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }
}

//* Class, represents button that can erase symbols from input of calculator
//* fullClear - (bool), if true the button will clear all symbols from input,
//*                     if false the button will clear one symbol at time
//* icon - (IconData), icon for button
final class DeleteButton extends StatelessWidget {
  const DeleteButton({super.key, required this.fullClear, required this.icon});

  final bool fullClear;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    var calculatorState = context.watch<CalculatorState>();

    return GestureDetector(
      onTap: fullClear
          ? () {
              calculatorState.inputClear();
            }
          : () {
              var currentInput = calculatorState.input;

              if (currentInput.isNotEmpty) {
                calculatorState.inputChange(
                    currentInput.substring(0, currentInput.length - 1));
              }
            },
      child: FractionallySizedBox(
        widthFactor: 0.3,
        heightFactor: 1,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          child: FittedBox(
            alignment: Alignment.center,
            child: Icon(
              icon,
            ),
          ),
        ),
      ),
    );
  }
}

//* Class represents button of the calculator
//* text - what symbol it will add to the input
//* computeButton - decides what type of button it will be, false - button that add numbers to the input
//*                                                         true - button that add '+','-','/','*' etc...
final class CalculatorButton extends StatelessWidget {
  const CalculatorButton(
      {super.key,
      required this.text,
      this.computeButton = false,
      this.fontSize = 24});

  final String text;
  final bool computeButton;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    var calculatorState = context.watch<CalculatorState>();

    return Flexible(
      child: GestureDetector(
        onTap: (computeButton
            ? () {
                var currentInput = calculatorState.input;

                if (currentInput.isEmpty) {
                  return;
                }

                if (currentInput[currentInput.length - 1]
                    .contains(RegExp(r'\d+'))) {
                  calculatorState.inputAppend(text);
                } else {
                  if (currentInput[currentInput.length - 1] != text) {
                    calculatorState.inputReplaceLast(text);
                  }
                }
              }
            : () {
                calculatorState.inputAppend(text);
              }),
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue,
            ),
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: fontSize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
