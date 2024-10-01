import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/common_widgets/round_gradient_button.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/workour_detail_view/widgets/step_detail_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:video_player/video_player.dart';

class ExercisesStepDetails extends StatefulWidget {
  final Map eObj;
  final String userId;
  const ExercisesStepDetails(
      {Key? key, required this.eObj, required this.userId})
      : super(key: key);

  @override
  State<ExercisesStepDetails> createState() => _ExercisesStepDetailsState();
}

class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SnackBar(
          content: Text("Progress saved successfully!"),
          duration: Duration(seconds: 2),
        ),
      ),
    );
  }
}

class _ExercisesStepDetailsState extends State<ExercisesStepDetails> {
  int selectedRepetitions = 15;
  late List<Map<String, String>> stepArr;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  VideoPlayerController _videoPlayerController =
      VideoPlayerController.asset('');
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _refreshPageAfterDelay();
    _videoPlayerController =
        VideoPlayerController.asset(widget.eObj["urlvideo"]);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
    );
    stepArr = [
      {
        "no": "01",
        "title": widget.eObj["destitle"],
        "detail": widget.eObj["descriptiontitle1"],
        "video": widget.eObj["urlvideo"],
      },
      {
        "no": "02",
        "title": widget.eObj["destitle2"],
        "detail": widget.eObj["descriptiontitle2"],
      },
      {
        "no": "03",
        "title": widget.eObj["destitle3"],
        "detail": widget.eObj["descriptiontitle3"],
      },
      {
        "no": "04",
        "title": widget.eObj["destitle4"],
        "detail": widget.eObj["descriptiontitle4"],
      },
    ];
  }

  void _refreshPageAfterDelay() {
    Future.delayed(Duration(seconds: 1), () {
      // Use the `setState` method to trigger a rebuild of the widget
      setState(() {});
    });
  }

  void _saveProgress(
      String userId, String exerciseTitle, int repetitions) async {
    final CollectionReference progressCollection =
        FirebaseFirestore.instance.collection('progress');

    try {
      await progressCollection.doc(userId).set(
        {exerciseTitle: repetitions},
        SetOptions(merge: true),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Progress saved successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while saving progress'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.eObj["urlvideo"]);
    print("gg");
    print(widget.eObj["urlvideo"].toString());
    var media = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/icons/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.lightGrayColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/icons/more_icon.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: media.width,
                    height: media.width * 0.43,
                    child: Chewie(
                      controller: ChewieController(
                        videoPlayerController: _videoPlayerController,
                        autoPlay: true,
                        looping: true,
                      ),
                    ),
                  ),
                  Container(
                    width: media.width,
                    height: media.width * 0.43,
                    decoration: BoxDecoration(
                        color: AppColors.blackColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                widget.eObj["title"].toString(),
                style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                "Easy | 390 Calories Burn",
                style: TextStyle(
                  color: const Color.fromARGB(255, 209, 204, 205),
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                "Descriptions",
                style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 4,
              ),
              ReadMoreText(
                widget.eObj["long"].toString(),
                trimLines: 4,
                colorClickableText: AppColors.blackColor,
                trimMode: TrimMode.Line,
                trimCollapsedText: ' Read More ...',
                trimExpandedText: ' Read Less',
                style: TextStyle(
                  color: const Color.fromARGB(255, 221, 216, 217),
                  fontSize: 12,
                ),
                moreStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "How To Do It",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "${stepArr.length} Sets",
                      style: TextStyle(
                          color: Color.fromARGB(255, 221, 220, 220),
                          fontSize: 12),
                    ),
                  )
                ],
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: stepArr.length,
                itemBuilder: ((context, index) {
                  var sObj = stepArr[index] as Map? ?? {};

                  return StepDetailRow(
                    sObj: sObj,
                    isLast: stepArr.last == sObj,
                  );
                }),
              ),
              Text(
                "Custom Repetitions",
                style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 150,
                child: CupertinoPicker.builder(
                  itemExtent: 40,
                  selectionOverlay: Container(
                    width: double.maxFinite,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                            color: Color.fromARGB(255, 223, 221, 221)
                                .withOpacity(0.2),
                            width: 1),
                        bottom: BorderSide(
                            color: const Color.fromARGB(255, 219, 219, 219)
                                .withOpacity(0.2),
                            width: 1),
                      ),
                    ),
                  ),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedRepetitions = (index + 1) * 15;
                    });
                  },
                  childCount: 60,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/burn_icon.png",
                          width: 15,
                          height: 15,
                          fit: BoxFit.contain,
                        ),
                        Text(
                          " ${(index + 1) * 15} Calories Burn",
                          style: TextStyle(
                              color: AppColors.grayColor, fontSize: 10),
                        ),
                        Text(
                          " ${index + 1} ",
                          style: TextStyle(
                              color: const Color.fromARGB(255, 211, 211, 211),
                              fontSize: 24,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          " times",
                          style: TextStyle(
                              color: const Color.fromARGB(255, 223, 220, 221),
                              fontSize: 16),
                        )
                      ],
                    );
                  },
                ),
              ),
              RoundGradientButton(
                title: "Save",
                onPressed: () {
                  _saveProgress(
                      widget.userId, widget.eObj["title"], selectedRepetitions);
                },
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
