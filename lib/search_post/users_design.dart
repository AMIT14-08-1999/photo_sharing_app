// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:photosharing/search_post/user.dart';
import 'package:photosharing/search_post/user_specification_posts.dart';

class UsersDesign extends StatefulWidget {
  Users? model;
  BuildContext? context;

  UsersDesign({
    Key? key,
    this.model,
    this.context,
  }) : super(key: key);

  @override
  State<UsersDesign> createState() => _UsersDesignState();
}

class _UsersDesignState extends State<UsersDesign> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UserSpecificationPosts(
              userId: widget.model!.id,
              userName: widget.model!.name,
            ),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 270,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.amberAccent,
                  minRadius: 90,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(
                      widget.model!.userImage!,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(widget.model!.name!,
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.pink,
                      fontSize: 20,
                    )),
                const SizedBox(height: 10),
                Text(widget.model!.email!,
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.pink,
                      fontSize: 20,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
