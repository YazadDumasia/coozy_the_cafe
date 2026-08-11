import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart' as shimmer;

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.imageUrl,
    super.key,
    this.isActive = false,
    this.hasBorder = false,
  });
  final String imageUrl;
  final bool isActive;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CircleAvatar(
          radius: 20.0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: CachedNetworkImage(
            fit: BoxFit.fill,
            imageUrl: imageUrl,
            imageBuilder: (context, imageProvider) {
              return CircleAvatar(
                radius: hasBorder ? 17.0 : 20.0,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: imageProvider,
              );
            },
            placeholder: (context, url) => shimmer.Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: CircleAvatar(
                radius: hasBorder ? 17.0 : 20.0,
                backgroundColor: Colors.grey[200],
              ),
            ),
            errorBuilder: (context, url, error) => CircleAvatar(
              radius: hasBorder ? 17.0 : 20.0,
              backgroundColor: Colors.grey.shade200,
              child: Image.asset(
                '',
                // StringImagePath.place_holder_profile_user,
                fit: BoxFit.fill,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        isActive
            ? PositionedDirectional(
                bottom: 0.0,
                end: 0.0,
                child: Container(
                  height: 15.0,
                  width: 15.0,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(width: 2.0, color: Colors.white),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
