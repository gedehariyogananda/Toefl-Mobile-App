import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:toefl/pages/full_test/bottom_sheet_transcript.dart';
import 'package:toefl/pages/full_test/toefl_audio_player.dart';
import 'package:toefl/utils/colors.dart';
import 'package:toefl/utils/hex_color.dart';
import 'package:toefl/widgets/answer_button.dart';
import 'package:toefl/widgets/answer_validation_container.dart';

import '../../models/test/answer.dart';
import '../../remote/env.dart';
import '../../utils/custom_text_style.dart';
import '../../widgets/blue_container.dart';

class ReviewFormSection extends StatelessWidget {
  const ReviewFormSection(
      {super.key, required this.answer, required this.number});

  final Answer answer;
  final int number;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        SizedBox(
          width: screenWidth * 0.92,
          height: screenHeight * 0.78,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                answer.typeQuestion == "Reading"
                    ? BlueContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HtmlWidget(
                              answer.nestedQuestion,
                            )
                          ],
                        ),
                      )
                    : answer.typeQuestion == "Listening"
                        ? ToeflAudioPlayer(
                            url: '${Env.storageUrl}/${answer.nestedQuestion}',
                          )
                        : const SizedBox(
                            height: 20,
                          ),
                const SizedBox(
                  height: 20,
                ),
                ..._buildQuestion(),
                const SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        ),
        Positioned(
            bottom: 20,
            right: 0,
            child: answer.typeQuestion == "Reading"
                ? _buildFloatingButton(context)
                : const SizedBox())
      ],
    );
  }

  List<Widget> _buildQuestion() {
    return [
      Text(
        "Question $number",
        style: CustomTextStyle.bold16.copyWith(fontSize: 14),
      ),
      const SizedBox(
        height: 8,
      ),
      answer.question.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 12),
              child: Text(
                answer.question,
                style: CustomTextStyle.medium14,
              ),
            )
          : const SizedBox(),
      Column(
        children: List.generate(4, (index) {
          return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: AnswerButton(
                onTap: () {
                  debugPrint(
                      "key : ${answer.keyQuestion} : ${answer.choices.length >= 4 ? answer.choices[index].id : "x"}");
                },
                isActive: false,
                title:
                    "(${String.fromCharCode(65 + index)}) ${answer.choices.length >= 4 ? answer.choices[index].choice : ""}",
                isAnswerTrue: answer.choices.length >= 4
                    ? answer.keyQuestion == answer.choices[index].choice
                    : false,
                isAnswerFalse: answer.choices.length >= 4
                    ? (answer.userAnswer == answer.choices[index].choice &&
                        !answer.isCorrect)
                    : false,
              ));
        }),
      ),
      const SizedBox(
        height: 12,
      ),
      answer.choices.length >= 4
          ? AnswerValidationContainer(
              isCorrect: answer.isCorrect,
              keyAnswer: answer.keyQuestion,
              explanation: "")
          : const SizedBox()
    ];
  }

  Widget _buildFloatingButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return BottomSheetTranscript(htmlText: answer.nestedQuestion);
            });
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
            color: HexColor(mariner500),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(1, 3),
              ),
            ]),
        child: Column(
          children: [
            const SizedBox(
              height: 6,
            ),
            Text(
              "See\nTranscript",
              textAlign: TextAlign.center,
              style: CustomTextStyle.bold16.copyWith(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
            const Icon(
              Icons.menu_book_outlined,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}