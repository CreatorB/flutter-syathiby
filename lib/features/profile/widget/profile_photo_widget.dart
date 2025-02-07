import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:syathiby/core/constants/image_constants.dart';
import 'package:syathiby/common/helpers/ui_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfilePhotoWidget extends StatelessWidget {
  final String ph = dotenv.env['PLACEHOLDER_IMAGE'] ?? "";
  final String? imageUrl;
  ProfilePhotoWidget({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(500)),
      child: CachedNetworkImage(
        fit: BoxFit.cover,
        width: UIHelper.deviceWidth * 0.12,
        imageUrl: imageUrl ?? ph,
        progressIndicatorBuilder: (context, url, progress) => const Center(
          child: CupertinoActivityIndicator(),
        ),
        errorWidget: (context, url, error) {
          return Image.asset(ImageConstants.defaultProfilePhoto);
        },
      ),
    );
  }
}
