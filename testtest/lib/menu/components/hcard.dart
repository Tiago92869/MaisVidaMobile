import 'package:flutter/material.dart';
import 'package:testtest/menu/models/courses.dart';

class HCard extends StatefulWidget {
  const HCard({Key? key, required this.section}) : super(key: key);

  final CourseModel section;

  @override
  _HCardState createState() => _HCardState();
}

class _HCardState extends State<HCard> {
  @override
  void initState() {
    super.initState();
    CourseModel.assignImagesToCourses(); // Assign images to all courses
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 110),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        color: widget.section.color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.section.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontFamily: "Poppins",
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.section.caption,
                  style: const TextStyle(
                    fontSize: 17,
                    fontFamily: "Inter",
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: VerticalDivider(thickness: 0.8, width: 0),
          ),
          Opacity(opacity: 0.9, child: Image.asset(
            widget.section.image,
            width: 48, // Set the width to 32
            height: 48, // Set the height to 32
            fit: BoxFit.contain, // Ensure the image fits within the bounds
          )),
          
        ],
      ),
    );
  }
}
