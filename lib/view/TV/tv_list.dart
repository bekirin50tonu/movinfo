import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movinfo/core/constants/app_constants.dart';
import 'package:movinfo/core/constants/navigation_constants.dart';
import 'package:movinfo/core/extensions/context_entensions.dart';
import 'package:movinfo/core/init/navigation/navigate_service.dart';
import 'package:movinfo/core/init/network/network_manager.dart';
import 'package:movinfo/core/view/movie/model/movie_model.dart';
import 'package:movinfo/core/view/tv/model/tv_model.dart';

class TVList extends StatefulWidget {
  final String path;
  const TVList({Key? key, required this.path}) : super(key: key);

  @override
  _TVListState createState() => _TVListState();
}

class _TVListState extends State<TVList> {
  StreamController<List<TVModel>> movieController = StreamController();
  List<TVModel> _items = [];
  int _itemCount = 0;

  //page scroll variables
  int _duration = 1;
  Cubic _curves = Curves.fastOutSlowIn;

  late ScrollController scrollController;
  int currentPage = 1;
  bool showFloatingActionButton = false;
  bool autoScroll = true;

  @override
  void initState() {
    scrollController = AppConstants.scrollController = ScrollController();
    super.initState();
    fetchData();
    var previousVariable = -1;
    var nextVariable = 1;
    scrollController.addListener(() {
      if (scrollController.hasClients) {
        /* print("Variable: " +
          variable.toString() +
          "\nScroll Position: " +
          scrollController.position.pixels.toString()); */
        if (autoScroll == true) {
          var variable =
              (scrollController.position.pixels / context.dynamicHeight(0.7))
                  .round();
          if (variable == nextVariable) {
            scrollController.animateTo(context.dynamicHeight(0.7) * variable,
                duration: Duration(seconds: _duration), curve: _curves);
            nextVariable++;
            previousVariable++;
          } else if (variable == previousVariable) {
            scrollController.animateTo(context.dynamicHeight(0.7) * variable,
                duration: Duration(seconds: _duration), curve: _curves);
            nextVariable--;
            previousVariable--;
          }
          if (scrollController.position.maxScrollExtent ==
              scrollController.position.pixels) {
            currentPage++;
            fetchData();
          }
        }

        if (scrollController.position.pixels > context.dynamicHeight(0.7)) {
          showFloatingActionButton = true;
        } else {
          showFloatingActionButton = false;
        }
        setState(() {});
      }
    });
  }

  void fetchData() async {
    TVModel items = await NetworkManager.instance.getData<TVModel>(
        widget.path,
        TVModel(),
        {'language': 'tr-TR', 'page': this.currentPage, 'region': ',TR'});
    print(widget.path);
    if (items == null || items.results == null) return;
    _itemCount += items.results!.length;
    _items.add(items);
    movieController.add(_items);
  }

  Widget noConnection(BuildContext context) {
    return Container(
        alignment: Alignment.bottomCenter,
        child: Text("Bağlantı Sağlanamadı!"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton:
            showFloatingActionButton && scrollController.hasClients
                ? FloatingActionButton(
                    child: Icon(Icons.arrow_upward_outlined),
                    onPressed: () async {
                      autoScroll = false;
                      await scrollController.animateTo(0,
                          duration: Duration(seconds: 2),
                          curve: Curves.fastOutSlowIn);
                      autoScroll = true;
                    },
                  )
                : null,
        body: StreamBuilder(
          stream: movieController.stream,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return noConnection(context);
              case ConnectionState.waiting:
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text("Yükleniyor..."),
                  ],
                ));
              case ConnectionState.active:
              case ConnectionState.done:
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _itemCount,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: BouncingScrollPhysics(),
                        controller: scrollController,
                        itemBuilder: (context, index) {
                          int dataIndex = index ~/ 20;
                          int resultIndex = index % 20;
                          /* print("DataIndex: " +
                          dataIndex.toString() +
                          "\nResultIndex: " +
                          resultIndex.toString() +
                          "\nIndex:" +
                          index.toString()); */
                          var data = snapshot.data[dataIndex];
                          return buildTvViewer(data, resultIndex);
                        },
                      ),
                    ),
                  ],
                );
            }
          },
        ));
  }

  buildTvViewer(TVModel data, int index) {
    final String baseUrl =
        "https://www.themoviedb.org/t/p/w600_and_h900_bestv2";
    final String posterPath = data.results![index].posterPath != null
        ? baseUrl + data.results![index].posterPath!
        : "https://img.utdstc.com/screen/780/8d3/7808d37d64f066960c7570274395f59d9ab4fcbb1f8512878fa5c53346f05e71:200";

    final releaseDate = data.results![index].firstAirDate != ""
        ? '${DateFormat("dd/MM/yyyy").format(DateTime.parse(data.results![index].firstAirDate!))}'
        : "";

    return InkWell(
        onTap: () => NavigationService.instance.navigateToPage(
            NavigationConstants.DETAIL_TV, data.results![index]),
        child: Column(children: [
          SizedBox(
            height: context.dynamicHeight(0.7),
            child: Card(
                color: context.media.platformBrightness == Brightness.dark
                    ? Colors.black87
                    : Colors.grey.shade300,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: CachedNetworkImage(
                          imageUrl: posterPath,
                          placeholder: (context, url) =>
                              new CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              new Icon(Icons.error),
                        ),
                      ),
                      Container(
                        child: ListTile(
                            title: Text(data.results![index].name!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 25,
                                    color: context.media.platformBrightness ==
                                            Brightness.dark
                                        ? Colors.grey
                                        : Colors.black)),
                            subtitle: ListTile(
                              title: Text(data.results![index].overview!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: context.media.platformBrightness ==
                                              Brightness.dark
                                          ? Colors.grey
                                          : Colors.black)),
                              subtitle: Text(
                                releaseDate,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: context.media.platformBrightness ==
                                            Brightness.dark
                                        ? Colors.grey
                                        : Colors.black),
                              ),
                            )),
                      ),
                    ])),
          )
        ]));
  }
}
