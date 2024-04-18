import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmer extends StatelessWidget {
  const CustomShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    var height =
        MediaQuery.of(context).size.height - AppBar().preferredSize.height;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade400,
        highlightColor: Colors.grey.shade100,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          width: MediaQuery.of(context).size.width * 0.45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.16,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  border: Border.all(color: Colors.transparent),
                ),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Container(
                color: Colors.white,
                width: double.infinity,
                height: 30,
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Container(
                color: Colors.white,
                width: double.infinity,
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
    ;
  }
}
