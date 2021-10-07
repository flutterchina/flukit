import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';

class SwiperRoute extends StatelessWidget {
  const SwiperRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final images = ["sea.png", "star.jpg", "cat.jpg", "horse.jpg"]
        .map((e) => Image.asset("imgs/$e", fit: BoxFit.fill))
        .toList();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: Swiper(
                indicatorAlignment: AlignmentDirectional.bottomEnd,
                speed: 400,
                controller: SwiperController(initialPage: 1),
                viewportFraction: .95,
                indicator: CircleSwiperIndicator(),
                onChanged: (index) => debugPrint('$index'),
                children: images
                    .map((e) => Padding(
                        child: e,
                        padding: const EdgeInsets.symmetric(horizontal: 1)))
                    .toList(),
              ),
            ),
            SizedBox(
              height: 200.0,
              child: Swiper(
                circular: true,
                //reverse: true, //反向
                indicator: RectangleSwiperIndicator(),
                children: images,
              ),
            ),
            AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: Swiper(
                indicatorAlignment: AlignmentDirectional.topEnd,
                circular: true,
                indicator: NumberSwiperIndicator(),
                children: images,
              ),
            ),
            AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: Swiper.builder(
                indicatorAlignment: AlignmentDirectional.topEnd,
                circular: true,
                childCount: images.length,
                indicator: NumberSwiperIndicator(),
                itemBuilder: (context, index) => images[index],
              ),
            ),
          ]
              .map((e) => Padding(
                  child: e, padding: const EdgeInsets.symmetric(vertical: 10)))
              .toList(),
        ),
      ),
    );
  }
}

class NumberSwiperIndicator extends SwiperIndicator {
  @override
  Widget build(BuildContext context, int index, int itemCount) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20.0),
      ),
      margin: const EdgeInsets.only(top: 10.0, right: 5.0),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      child: Text(
        "${++index}/$itemCount",
        style: const TextStyle(color: Colors.white70, fontSize: 11.0),
      ),
    );
  }
}
