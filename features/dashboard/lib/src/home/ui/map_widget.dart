import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:dashboard/src/home/ui/tile_providers.dart';
import 'package:flutter/material.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter_map_marker_cluster_2/flutter_map_marker_cluster.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;

class MapWidget extends StatefulWidget {
  const MapWidget({
    required this.width,
    this.reports,
    this.dumps,
    this.reportStatistics,
    required this.isHovering,
    required this.onCategoryChange,
    required this.category,
    this.onInformationTap,
    //required this.cameraPosition,
    required this.isMobile,
    super.key,
  });

  final double width;
  final List<PublicReportDto>? reports;
  final List<DumpDto>? dumps;
  final ReportStatisticsDto? reportStatistics;
  final ValueChanged<bool> isHovering;
  final Function(String) onCategoryChange;
  final Function(String)? onInformationTap;

  //final CameraPosition cameraPosition;
  final String category;
  final bool isMobile;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final CustomInfoWindowController _customReportInfoWindowController =
      CustomInfoWindowController();

  //BitmapDescriptor trashMarkerIcon = BitmapDescriptor.defaultMarker;
  bool isShowMarkers = false;
  bool isShowDumps = false;
  List<Marker> _markers = [];
  late bool isMapHover;
  bool isTrash = false;
  String? initialItem;

  //late MapType _currentMapType;
  // late CameraPosition _cameraPosition;
  // late GoogleMapController mapController;
  bool isLocationLoading = false;

  static const List<String> _dropdownList = [
    'Atliekos',
    'Sugadinta miško paklotė ir keliai',
    'Pažeidimai kirtimuose',
  ];

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    //_cameraPosition = widget.cameraPosition;
    mapMarkers();
    if (widget.category == 'trash' || widget.category == 'dumps') {
      initialItem = 'Atliekos';
    } else if (widget.category == 'forest') {
      initialItem = 'Sugadinta miško paklotė ir keliai';
    } else if (widget.category == 'permits') {
      initialItem = 'Pažeidimai kirtimuose';
    }

    if (widget.category == 'dumps') {
      isShowDumps = true;
    }

    //_currentMapType = MapType.normal;
    super.initState();
  }

  //
  // void _onMapCreated(GoogleMapController controller) {
  //   mapController = controller;
  // }

  Future<Position> getCurrentLocation() async {
    setState(() {
      isLocationLoading = true;
    });
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      isLocationLoading = false;
    });
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isMobile) ...[
          SizedBox(height: widget.width * 0.0278),
          SizedBox(
            width: widget.width * 0.911,
            child: PointerInterceptor(
              child: CustomDropdown<String>(
                hintText: 'Pasirinkite kategoriją',
                decoration: CustomDropdownDecoration(
                  listItemStyle: GoogleFonts.roboto(
                    fontSize: widget.width * 0.036,
                  ),
                  hintStyle: GoogleFonts.roboto(
                    fontSize: widget.width * 0.036,
                  ),
                  headerStyle: GoogleFonts.roboto(
                    fontSize: widget.width * 0.036,
                  ),
                ),
                items: _dropdownList,
                initialItem: initialItem,
                onChanged: (value) {
                  widget.onCategoryChange(getDropdownValueByString(value!));
                },
              ),
            ),
          ),
          SizedBox(height: widget.width * 0.0278),
        ] else ...[
          SizedBox(height: widget.width * 0.03125),
        ],
        MouseRegion(
          onEnter: (event) {
            widget.isHovering(true);
          },
          onExit: (event) {
            widget.isHovering(false);
          },
          child: Stack(
            children: [
              Column(
                children: <Widget>[
                  SizedBox(
                    height: widget.isMobile
                        ? widget.width * 1.722
                        : widget.width * 0.4765,
                    width: widget.isMobile
                        ? widget.width * 0.9112
                        : widget.width * 0.84375,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                          Radius.circular(widget.isMobile ? 8 : 32)),
                      child: Stack(
                        children: [
                          FlutterMap(
                              options: MapOptions(
                                  
                                  initialCenter: latlong.LatLng(55, 24),
                                  initialZoom: 7),
                              children: [
                                openStreetMapTileLayer,
                                //MarkerLayer(markers: _markers)
                                MarkerClusterLayerWidget(
                                  options: MarkerClusterLayerOptions(
                                    maxClusterRadius: 80,
                                    size: const Size(40, 40),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(50),
                                    maxZoom: 15,
                                    markers: _markers,
                                    builder: (context, markers) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Colors.green),
                                        child: Center(
                                          child: Text(
                                            markers.length.toString(),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ]),
                          // GoogleMap(
                          //   mapType: _currentMapType,
                          //   initialCameraPosition: _cameraPosition,
                          //   markers: _markers,
                          //   myLocationButtonEnabled: true,
                          //   myLocationEnabled: true,
                          //   onMapCreated:
                          //       (GoogleMapController controller) async {
                          //     _onMapCreated(controller);
                          //     _customReportInfoWindowController
                          //         .googleMapController = controller;
                          //   },
                          //   onCameraMove: (position) {
                          //     _customReportInfoWindowController.onCameraMove!();
                          //     updateCamera(position);
                          //   },
                          //   onTap: (position) {
                          //     _customReportInfoWindowController
                          //         .hideInfoWindow!();
                          //   },
                          // ),
                          // CustomInfoWindow(
                          //   (top, left, width, height) => {},
                          //   leftMargin: 200,
                          //   controller: _customReportInfoWindowController,
                          //   isDump: isShowDumps,
                          // ),
                          Positioned(
                            bottom: 155,
                            right: 10,
                            child: PointerInterceptor(
                              child: InkWell(
                                  onTap: () {},
                                  child: LocationSearchButton(
                                    width: 40,
                                    height: 40,
                                    onPressed: () async {
                                      Position position =
                                          await getCurrentLocation();
                                      // setState(() {
                                      //   mapController.animateCamera(
                                      //       CameraUpdate.newLatLngZoom(
                                      //           LatLng(position.latitude,
                                      //               position.longitude),
                                      //           16));
                                      // });
                                    },
                                    isLoading: isLocationLoading,
                                  )),
                            ),
                          ),
                          if (!widget.isMobile) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 20, right: 20),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: SizedBox(
                                  width: widget.width * 0.3,
                                  child: PointerInterceptor(
                                    child: CustomDropdown<String>(
                                      hintText: 'Pasirinkite kategoriją',
                                      decoration: CustomDropdownDecoration(
                                        listItemStyle: GoogleFonts.roboto(
                                          fontSize: widget.width * 0.0102,
                                        ),
                                        hintStyle: GoogleFonts.roboto(
                                          fontSize: widget.width * 0.0102,
                                        ),
                                        headerStyle: GoogleFonts.roboto(
                                          fontSize: widget.width * 0.0102,
                                        ),
                                      ),
                                      items: _dropdownList,
                                      initialItem: initialItem,
                                      onChanged: (value) {
                                        widget.onCategoryChange(
                                            getDropdownValueByString(value!));
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                          // Padding(
                          //   padding:
                          //       const EdgeInsets.only(bottom: 110, right: 10),
                          //   child: Align(
                          //       alignment: Alignment.bottomRight,
                          //       child: PointerInterceptor(
                          //         child: GoogleMapTypeButton(
                          //           height: 40,
                          //           width: 40,
                          //           onPressed: () {
                          //             showDialog<String>(
                          //                 context: context,
                          //                 builder: (BuildContext context) =>
                          //                     MapTypeChangeDialog(
                          //                       width: widget.width,
                          //                       currentMapType: _currentMapType,
                          //                       onChangeTap: (MapType mapType) {
                          //                         setState(() {
                          //                           _currentMapType = mapType;
                          //                         });
                          //                       },
                          //                       isMobile: widget.isMobile,
                          //                     ));
                          //           },
                          //         ),
                          //       )),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              widget.category == 'dumps' || widget.category == 'trash'
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: widget.isMobile ? 8 : 20,
                        left: widget.isMobile ? 0 : 20,
                      ),
                      child: Align(
                        alignment: widget.isMobile
                            ? Alignment.topCenter
                            : Alignment.topLeft,
                        child: ReportTypeSwitcher(
                          isShowDumps: widget.category == 'dumps',
                          onReportTypeChange: (value) {
                            widget.onCategoryChange(value);
                          },
                          isMobile: widget.isMobile,
                          width: widget.width,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
        SizedBox(height: widget.width * 0.0135),
        if (widget.category != 'dumps' && !widget.isMobile) ...[
          ReportStatistics(
            reportStatistics: widget.reportStatistics!,
          ),
          SizedBox(
            height: widget.width * 0.033,
          ),
          ReportTable(
            width: widget.width,
            reports: widget.reports!,
            onInformationTap: (refId) {
              widget.onInformationTap!(refId);
            },
          ),
        ]
      ],
    );
  }

  // Future<void> updateCamera(CameraPosition cameraPosition) async {
  //   await SecureStorageProvider().setCameraSetup(cameraPosition);
  // }

  getDropdownValueByString(String value) {
    switch (value) {
      case 'Atliekos':
        return 'trash';
      case 'Sugadinta miško paklotė ir keliai':
        return 'forest';
      case 'Pažeidimai kirtimuose':
        return 'permits';
    }
  }

  Future<void> mapMarkers() async {
    int index = 1000;
    List<Marker> tempMarkers = [];
    if (widget.reports != null) {
      for (var element in widget.reports!) {
        tempMarkers.add(
          Marker(
            point: latlong.LatLng(element.latitude, element.longitude),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: InfoTrashWindowBox(
                        title: element.name,
                        imageUrls: element.imageUrls.toList(),
                        status: element.status,
                        date: element.reportDate.toString(),
                        reportId: element.refId,
                        onTap: () {
                          widget.onInformationTap!(element.refId);
                        }),
                  ),
                );
              },
              child: Image.asset(
                getTrashIconPath(element.status),
                height: 20,
                width: 20,
              ),
            ),
          ),
          // Marker(
          //     markerId: MarkerId(
          //       element.name.toString() + index.toString(),
          //     ),
          //     position: LatLng(
          //       element.latitude.toDouble(),
          //       element.longitude.toDouble(),
          //     ),
          //     icon: await BitmapDescriptor.asset(
          //         const ImageConfiguration(size: Size(25, 30)),
          //         getTrashIconPath(element.status)),
          //     onTap: () {
          //       _customReportInfoWindowController.addInfoWindow!(
          //         InfoTrashWindowBox(
          //             title: element.name,
          //             imageUrls: element.imageUrls.toList(),
          //             status: element.status,
          //             date: element.reportDate.toString(),
          //             reportId: element.refId,
          //             onTap: () {
          //               widget.onInformationTap!(element.refId);
          //             }),
          //         LatLng(
          //           element.latitude.toDouble(),
          //           element.longitude.toDouble(),
          //         ),
          //       );
          //     }),
        );
        index++;
      }
    } else if (widget.dumps != null) {
      for (var element in widget.dumps!) {
        tempMarkers.add(
          Marker(
            point: latlong.LatLng(element.reportLat, element.reportLong),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: InfoDumpWindowBox(
                      title: element.name,
                      address: element.address ?? '',
                      phone: element.phone ?? '',
                      workingHours: element.workingHours,
                      moreInformation: element.moreInformation,
                      isHovering: (bool value) {
                        setState(() {
                          isMapHover = value;
                        });
                      },
                    ),
                  ),
                );
              },
              child: SvgPicture.asset(
                'assets/svg/dump_icon.svg',
                height: 20,
                width: 20,
              ),
            ),
          ),
          // Marker(
          //     markerId: MarkerId(
          //       element.name.toString() + index.toString(),
          //     ),
          //     position: LatLng(
          //       element.reportLat.toDouble(),
          //       element.reportLong.toDouble(),
          //     ),
          //     icon: await BitmapDescriptor.asset(
          //         const ImageConfiguration(size: Size(50, 50)),
          //         'assets/svg/dump_icon.svg'),
          //     onTap: () {
          //       _customReportInfoWindowController.addInfoWindow!(
          //         InfoDumpWindowBox(
          //           title: element.name,
          //           address: element.address ?? '',
          //           phone: element.phone ?? '',
          //           workingHours: element.workingHours,
          //           moreInformation: element.moreInformation,
          //           isHovering: (bool value) {
          //             setState(() {
          //               isMapHover = value;
          //             });
          //           },
          //         ),
          //         LatLng(
          //           element.reportLat.toDouble(),
          //           element.reportLong.toDouble(),
          //         ),
          //       );
          //     }),
        );
        index++;
      }
    }

    setState(() {
      _markers = tempMarkers;
      tempMarkers = [];
    });
  }

  String getTrashIconPath(String status) {
    if (status == "gautas") {
      return 'assets/icons/marker_pins/red_marker.png';
    } else if (status == "tiriamas") {
      return 'assets/icons/marker_pins/orange_marker.png';
    } else if (status == "išspręsta") {
      return 'assets/icons/marker_pins/green_marker.png';
    } else if (status == "nepasitvirtino") {
      return 'assets/icons/marker_pins/gray_marker.png';
    } else {
      return 'assets/icons/marker_pins/red_marker.png';
    }
  }
}
