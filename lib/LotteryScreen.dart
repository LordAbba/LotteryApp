import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottery/LotteryController.dart';

class LotteryScreen extends StatelessWidget {
  const LotteryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize the lottery controller
    final LotteryController controller = Get.put(LotteryController());

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF39C12), // Light orange
                Color(0xFFE67E22), // Dark orange
              ],
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              _buildSelectedNumbers(controller),
              Expanded(
                child: Obx(() => controller.isManualMode.value
                    ? _buildNumberGrid(controller)
                    : _buildAutoPickSection(controller),
                ),
              ),
              _buildActionButtons(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Lottery Draw',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedNumbers(LotteryController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select numbers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() => Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: InkWell(
                  onTap: controller.isAnimating.value ? null : () {
                    controller.toggleMode(false);
                    controller.generateRandomNumbers();
                  },
                  child: Row(
                    children: [
                      controller.isAnimating.value
                          ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                      )
                          : Icon(Icons.refresh, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        controller.isAnimating.value ? 'SELECTING...' : 'LUCKY DIP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 12),
          _buildNumberBalls(controller),
        ],
      ),
    );
  }

  Widget _buildNumberBalls(LotteryController controller) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        final hasNumber = index < controller.selectedNumbers.length;
        final isCurrentlyAnimating = controller.isAnimating.value &&
            index == controller.currentAnimatingIndex.value;

        // The number to display - either selected number, currently animating number, or empty
        final displayNumber = hasNumber ? controller.selectedNumbers[index] :
        (isCurrentlyAnimating ? controller.currentHighlightedNumber.value : null);

        // Color of the ball based on state
        final ballColor = hasNumber ?
        [const Color(0xFF3498DB), const Color(0xFFE74C3C), const Color(0xFFF39C12), const Color(0xFF9B59B6)][index % 4] :
        (isCurrentlyAnimating ? Colors.amber.shade700 : Colors.white);

        // Animation scale effect
        final scale = isCurrentlyAnimating ? 1.15 : 1.0;

        return TweenAnimationBuilder(
            tween: Tween<double>(begin: 1.0, end: scale),
            duration: const Duration(milliseconds: 150),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ballColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: isCurrentlyAnimating ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        spreadRadius: 1,
                      )
                    ] : null,
                  ),
                  child: Center(
                    child: displayNumber != null
                        ? Text(
                      displayNumber.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                        : const Text(''),
                  ),
                ),
              );
            }
        );
      }),
    ));
  }

  Widget _buildNumberGrid(LotteryController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF39C12).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 50,
          itemBuilder: (context, index) {
            final number = index + 1;
            return Obx(() {
              final isSelected = controller.isSelected(number);
              // Also highlight currently animating number
              final isHighlighted = controller.isAnimating.value &&
                  controller.currentHighlightedNumber.value == number;

              return InkWell(
                onTap: controller.isAnimating.value ? null : () {
                  if (isSelected || !controller.isMaxSelected) {
                    controller.toggleNumber(number);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ?
                    [const Color(0xFF3498DB), const Color(0xFFE74C3C),
                      const Color(0xFFF39C12), const Color(0xFF9B59B6)][index % 4] :
                    (isHighlighted ? Colors.amber.shade600 : Colors.white),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                    boxShadow: isHighlighted ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        spreadRadius: 1,
                      )
                    ] : null,
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: TextStyle(
                        color: (isSelected || isHighlighted) ? Colors.white : Colors.black,
                        fontWeight: (isSelected || isHighlighted) ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Widget _buildAutoPickSection(LotteryController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF39C12).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Auto Pick Mode',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Obx(() => ElevatedButton.icon(
                icon: controller.isAnimating.value
                    ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                )
                    : const Icon(Icons.refresh),
                label: Text(
                  controller.isAnimating.value
                      ? 'Selecting Numbers...'
                      : 'Generate New Numbers',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: controller.isAnimating.value ? null : () {
                  controller.generateRandomNumbers();
                },
              )),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextButton(
                onPressed: controller.isAnimating.value ? null : () {
                  controller.toggleMode(true);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Switch to Manual Pick',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(LotteryController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey[800],
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              onPressed: controller.isAnimating.value ? null : () {
                controller.reset();
              },
              child: const Text(
                'RESET',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              onPressed: (controller.canProceed && !controller.isAnimating.value) ? () {
                // Here you'd implement the "proceed" action
                Get.snackbar(
                  'Success!',
                  'Your numbers have been submitted.',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } : null,
              child: const Text(
                'DONE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}