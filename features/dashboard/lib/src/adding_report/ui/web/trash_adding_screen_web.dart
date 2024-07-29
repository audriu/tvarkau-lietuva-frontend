import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:dashboard/src/adding_report/ui/widgets/explanation_dialog_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:core_ui/core_ui.dart';
import 'dart:typed_data';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../widgets/adding_screen_side_bar.dart';

class TrashAddingScreenWeb extends StatefulWidget {
  const TrashAddingScreenWeb({
    required this.width,
    required this.height,
    required this.reports,
    required this.onAddTap,
    super.key,
  });

  final double width;
  final double height;
  final List<PublicReportDto> reports;
  final Function(String, String, double, double, List<Uint8List>) onAddTap;

  @override
  State<TrashAddingScreenWeb> createState() => _TrashAddingScreenWebState();
}

class _TrashAddingScreenWebState extends State<TrashAddingScreenWeb> {
  List<Uint8List> _selectedImages = [];

  Future<void> getMultipleImageInfos() async {
    final images = await AppImagePicker().pickMultipleImages();

    setState(() {
      _selectedImages = (_selectedImages + images)
          .take(GlobalConstants.maxAllowedImageCount)
          .toList();
      calculateImagesSize();
    });
  }

  bool isTermsAccepted = false;
  final _formKey = GlobalKey<FormState>();
  bool isShowMarkers = true;
  bool isMapDisabled = false;
  bool isImagesSizeValid = true;

  String currentTextValue = '';
  String currentEmailValue = '';

  double selectedLat = 0;
  double selectedLong = 0;

  bool _isLoading = false;

  void removeSelectedImage(int imageIndex) {
    setState(() {
      _selectedImages.removeAt(imageIndex);
      calculateImagesSize();
    });
  }

  @override
  void initState() {
    getLocation();
    super.initState();
  }

  getLocation() async {
    setState(() {
      _isLoading = true;
    });
  }

  void calculateImagesSize() {
    var imageSizes = 0;
    for (var element in _selectedImages) {
      imageSizes += element.lengthInBytes;
    }
    if (imageSizes > GlobalConstants.maxAllowedImageSizeInBytes) {
      isImagesSizeValid = false;
    } else {
      isImagesSizeValid = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Title(
      title: "Pranešti apie atliekas",
      color: const Color.fromRGBO(28, 63, 58, 1),
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(250, 242, 234, 1),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Form(
              key: _formKey,
              child: Row(
                children: <Widget>[
                  Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      SizedBox(
                        height: constraints.maxHeight,
                        width: constraints.maxWidth * 0.68125,
                        // child: _isLoading
                        //     ? Stack(
                        //         children: [
                        //           Opacity(
                        //             opacity: 0.5,
                        //             child: GoogleMap(
                        //               onMapCreated: _onMapCreated,
                        //               buildingsEnabled: true,
                        //               initialCameraPosition:
                        //                   _lithuaniaCameraPosition,
                        //               mapType: currentMapType,
                        //               onTap: null,
                        //               markers: isShowMarkers
                        //                   ? markers
                        //                   : addedMarker.map((e) => e).toSet(),
                        //             ),
                        //           ),
                        //           Center(
                        //             child: LoadingAnimationWidget
                        //                 .staggeredDotsWave(
                        //               color: AppTheme.mainThemeColor,
                        //               size: 150,
                        //             ),
                        //           ),
                        //         ],
                        //       )
                        //     : GoogleMap(
                        //         onMapCreated: _onMapCreated,
                        //         buildingsEnabled: true,
                        //         initialCameraPosition: _lithuaniaCameraPosition,
                        //         mapType: currentMapType,
                        //         onTap: _handleTap,
                        //         markers: isShowMarkers
                        //             ? markers
                        //             : addedMarker.map((e) => e).toSet(),
                        //       ),
                      ),
                      true
                          ? Positioned(
                              bottom: 155,
                              right: 10,
                              child: InkWell(
                                  onTap: () {},
                                  onHover: (isHover) {
                                    setState(() {
                                      isMapDisabled = isHover;
                                    });
                                  },
                                  child: PointerInterceptor(
                                    child: LocationSearchButton(
                                      width: 40,
                                      height: 40,
                                      onPressed: () {
                                        setState(() async {
                                          await getLocation();
                                        });
                                      },
                                      isLoading: _isLoading,
                                    ),
                                  )),
                            )
                          : const SizedBox.shrink(),
                      Positioned(
                        bottom: 110,
                        right: 10,
                        child: InkWell(
                          onTap: () {},
                          onHover: (isHover) {
                            setState(() {
                              isMapDisabled = isHover;
                            });
                          },
                          child: PointerInterceptor(
                            child: GoogleMapTypeButton(
                              height: 40,
                              width: 40,
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  AddingScreenSideBar(
                    width: widget.width,
                    height: widget.height,
                    title: 'Pranešti apie atliekas gamtoje',
                    onExitTap: () {
                      context.goNamed("home");
                    },
                    onImageAddTap: () {
                      getMultipleImageInfos();
                    },
                    onFinalTap: () async {
                      if (_formKey.currentState!.validate() &&
                          selectedLat != 0 &&
                          selectedLong != 0 &&
                          isTermsAccepted &&
                          _selectedImages.isNotEmpty &&
                          isImagesSizeValid) {
                        if (_selectedImages.length >= 2) {
                          widget.onAddTap(
                            currentEmailValue,
                            currentTextValue,
                            selectedLat,
                            selectedLong,
                            _selectedImages,
                          );
                        }
                      }
                    },
                    onImageRemoveTap: (index) {
                      removeSelectedImage(index);
                    },
                    onTextChange: (textValue) {
                      setState(() {
                        currentTextValue = textValue;
                      });
                    },
                    onEmailChange: (emailValue) {
                      setState(() {
                        currentEmailValue = emailValue;
                      });
                    },
                    selectedImages: _selectedImages,
                    onTermsChange: (termsValue) {
                      setState(() {
                        isTermsAccepted = termsValue;
                      });
                    },
                    isImagesSizeValid: isImagesSizeValid,
                    isTermsAccepted: isTermsAccepted,
                    category: 'trash',
                    onExplanationTap: () {
                      showDialog(
                          context: context,
                          barrierColor: Colors.white.withOpacity(0),
                          builder: (context) {
                            return ExplanationDialogWidget(
                              width: widget.width,
                              category: 'trash',
                              isMobile: false,
                            );
                          });
                    },
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
