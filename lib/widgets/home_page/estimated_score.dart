import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toefl/models/estimated_score.dart' as model;
import 'package:toefl/remote/api/estimated_score.dart';
import 'package:toefl/utils/colors.dart';
import 'package:toefl/utils/hex_color.dart';
import 'package:toefl/widgets/toefl_progress_indicator.dart';


class EstimatedScoreWidget extends StatefulWidget {
  EstimatedScoreWidget({super.key});

  @override
  State<EstimatedScoreWidget> createState() => _EstimatedScoreWidgetState();
}

class _EstimatedScoreWidgetState extends State<EstimatedScoreWidget> {
  final estimatedScoreApi = EstimatedScoreApi();
  model.EstimatedScore? estimatedScore;
  Map<String, dynamic> score = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchEstimatedScore();
  }

  void fetchEstimatedScore() async {
    setState(() {
      isLoading = true;
    });
    try {
      model.EstimatedScore temp = await estimatedScoreApi.getEstimatedScore();

      setState(() {
        estimatedScore = temp;
        score = {
          'Listening Score': temp.scoreListening,
          'Structure Score': temp.scoreStructure,
          'Reading Score': temp.scoreReading,
        };
      });
    } catch (e) {
      print("Error in fetchEstimatedScore: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 4.5,
      child: PageView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Skeletonizer(
            enabled: isLoading,
            child: Skeleton.leaf(
              child: LayoutBuilder(builder: (context, constraint) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: HexColor(mariner800)),
                      margin: EdgeInsets.symmetric(horizontal: 24),
                    ),
                    Positioned(
                        top: (constraint.maxHeight / 20),
                        right: -(constraint.maxHeight / 20),
                        child: SvgPicture.asset(
                          "assets/images/vector_bg_ec.svg",
                          width: constraint.maxHeight / 0.5,
                          // width: 600,
                        )),
                    Positioned(
                        child: Container(
                      width: MediaQuery.of(context).size.height / 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${estimatedScore?.userScore}",
                                      style: TextStyle(
                                          fontSize: constraint.maxHeight / 7,
                                          fontWeight: FontWeight.w800,
                                          height: 0.9,
                                          color: HexColor(mariner300)),
                                    ),
                                    Text(
                                      "/${estimatedScore?.targetUser}",
                                      style: TextStyle(
                                          fontSize: constraint.maxHeight / 10,
                                          fontWeight: FontWeight.w800,
                                          color: HexColor(neutral20)),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                child: ToeflProgressIndicator(
                                  value: (estimatedScore?.userScore ?? 0) /
                                      _getTargetScore(),
                                  scale: constraint.maxHeight / 150,
                                  strokeWidth: constraint.maxHeight / 10,
                                  strokeScaler: constraint.maxHeight / 180,
                                  activeHexColor: mariner100,
                                  nonActiveHexColor: mariner300,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // "Estimated score",
                                "Estimated score",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: HexColor(mariner200),
                                    height: 2),
                              ),
                              ...score.entries.map(
                                (entry) => Text(
                                  '${entry.key}: ${entry.value}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: HexColor(neutral10),
                                  ),
                                ),
                              ),
                              Text("*take a full test to show here",
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w300,
                                      color: HexColor(neutral10),
                                      height: 2)),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
                                child: TextButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                  ),
                                  child: Text(
                                    "Set Now",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: HexColor(mariner900)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )),
                  ],
                );
              }),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: HexColor(mariner900)),
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ModalConfirmation(
                        message: "Are you sure want to logout this account?",
                        disbleName: "Cancel",
                        enableName: "Logout",
                      );
                    },
                  );
                },
                child: Text(
                  "Try",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: HexColor(mariner900)),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                )),
          ),
        ],
      ),
    );
  }

  int _getTargetScore() {
    var tmp = estimatedScore?.targetUser ?? 0;
    return tmp <= 0 ? 1 : tmp;
  }
}
