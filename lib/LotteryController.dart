import 'dart:math';
import 'dart:async';
import 'package:get/get.dart';

class LotteryController extends GetxController {
  final RxBool isManualMode = true.obs;

  final RxList<int> selectedNumbers = <int>[].obs;

  final int maxSelections = 6;

  final RxBool isAnimating = false.obs;
  final RxInt currentAnimatingIndex = 0.obs;
  final RxInt currentHighlightedNumber = 1.obs;

  final List<Timer> _activeTimers = [];

  void toggleMode(bool manual) {
    isManualMode.value = manual;
  }

  void toggleNumber(int number) {
    if (selectedNumbers.contains(number)) {
      selectedNumbers.remove(number);
    } else if (selectedNumbers.length < maxSelections) {
      selectedNumbers.add(number);
    }
  }

  bool isSelected(int number) {
    return selectedNumbers.contains(number);
  }

  bool get isMaxSelected => selectedNumbers.length >= maxSelections;

  bool get canProceed => selectedNumbers.length == maxSelections;

  void generateRandomNumbers() {
    _cancelActiveTimers();

    selectedNumbers.clear();

    isAnimating.value = true;
    currentAnimatingIndex.value = 0;

    _animateNumberSelection();
  }

  void _animateNumberSelection() {
    final random = Random();

    final List<int> targetNumbers = _generateUniqueRandomNumbers();
    final int targetNumber = targetNumbers[currentAnimatingIndex.value];

    int ticks = 0;
    final totalTicks = 15;

    final fastTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      currentHighlightedNumber.value = random.nextInt(50) + 1;
      ticks++;


      if (ticks >= totalTicks) {
        timer.cancel();
        _activeTimers.remove(timer);


        final slowTimer = Timer.periodic(Duration(milliseconds: 150), (timer) {

          int currentNum = currentHighlightedNumber.value;
          int distance = (targetNumber - currentNum).abs();


          int step;
          if (distance > 10) {
            step = random.nextInt(5) + 3;
          } else if (distance > 5) {
            step = random.nextInt(3) + 2;
          } else {
            step = 1;
          }

          if (currentNum < targetNumber) {
            currentHighlightedNumber.value += step;
            if (currentHighlightedNumber.value > 50) {
              currentHighlightedNumber.value = currentHighlightedNumber.value - 50;
            }
          } else {
            currentHighlightedNumber.value -= step;
            if (currentHighlightedNumber.value < 1) {
              currentHighlightedNumber.value = 50 + currentHighlightedNumber.value;
            }
          }

          if (currentHighlightedNumber.value == targetNumber) {
            timer.cancel();
            _activeTimers.remove(timer);

            selectedNumbers.add(targetNumber);

            currentAnimatingIndex.value++;
            if (currentAnimatingIndex.value < maxSelections) {
              Future.delayed(Duration(milliseconds: 300), () {
                _animateNumberSelection();
              });
            } else {

              isAnimating.value = false;

              // to gather the numbers for the final display
              selectedNumbers.sort();
            }
          }
        });
        _activeTimers.add(slowTimer);
      }
    });
    _activeTimers.add(fastTimer);
  }

  // Generate unique random numbers all at once, at the beginning
  List<int> _generateUniqueRandomNumbers() {
    final random = Random();
    final Set<int> numbers = {};

    // to generate random numbers
    while (numbers.length < maxSelections) {
      numbers.add(random.nextInt(50) + 1);
    }

    return numbers.toList();
  }

  // This cancels active timers for the animation
  void _cancelActiveTimers() {
    for (var timer in _activeTimers) {
      if (timer.isActive) {
        timer.cancel();
      }
    }
    _activeTimers.clear();
  }

  // This resets selected numbers
  void reset() {
    _cancelActiveTimers();
    isAnimating.value = false;
    selectedNumbers.clear();
  }

  @override
  void onClose() {
    _cancelActiveTimers();
    super.onClose();
  }
}