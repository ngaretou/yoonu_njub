import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yoonu_njub/l10n/app_localizations.dart'; // the new Flutter 3.x localization method
import 'package:hive_flutter/hive_flutter.dart';
import '../main.dart';
import '../providers/shows.dart';
import '../providers/theme.dart';

class DownloadButton extends StatefulWidget {
  final Show show;
  final double? iconSize;
  final bool showArrow;
  final bool autoDownload;
  const DownloadButton(this.show,
      {this.iconSize,
      this.showArrow = true,
      this.autoDownload = false,
      super.key});

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  late bool _isDownloaded;
  bool _isDownloading = false;
  double? _percentDone;

  //path is the local app Document path; url is the WHOLE url you need to download, filename is just the filename
  Future downloadFile(String path, String urlbase, Show show) async {
    //here we set the flag to true so we don't restart the process
    setState(() {
      _isDownloading = true;
    });
    //This will hold the downloaded file temporarily before writing
    List<int> bytes = [];
    String url = '$urlbase/${show.urlSnip}/${show.filename}';
    final http.StreamedResponse response =
        await http.Client().send(http.Request('GET', Uri.parse(url)));
    //total size of download
    final total = response.contentLength ?? 0;

    var received = 0;
    //Here we listen to the stream an monitor it so we nkow how much has been downloaded, which allows us to calculate the percentage done
    //https://medium.com/flutter-community/how-to-show-download-progress-in-a-flutter-app-8810e294acbd
    response.stream.listen((value) {
      if (!mounted) return;
      setState(() {
        bytes.addAll(value);
        received += value.length;
        _percentDone = ((received) / total);
      });
    }, onDone: () async {
      final file = File("$path/${show.filename}");
      await file.writeAsBytes(bytes);
      debugPrint('download done');
      downloadedBox.put((show.id), true);

      _isDownloading = false;
    }, onError: (e) {
      debugPrint(
          'had an error checking if the file was there or not - downloadFile()');
      debugPrint(e);
    }, cancelOnError: true);
  }

  @override
  Widget build(BuildContext context) {
    print('building Download button');
    final shows = Provider.of<Shows>(context, listen: false);
    final pref = Provider.of<ThemeModel>(context, listen: false);

    Future<String> getDownloadSize(url) async {
      final http.Response r = await http.head(Uri.parse(url));
      final total = r.headers["content-length"]!;
      final totalAsInt = double.parse(total);
      final String totalFormatted = (totalAsInt / 1000000).toStringAsFixed(2);

      return totalFormatted;
    }

    //This either deletes the file if it's on the device or downloads it if not.
    Future<void> downloadOrDeleteFile(String urlbase, Show show) async {
      //putting together the whole url for the show we're looking at
      String url = '${shows.urlBase}/${show.urlSnip}/${show.filename}';
      //If you are not already downloading something...
      if (!_isDownloading) {
        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path;
        debugPrint(directory.path);
        //see if it's on the device
        try {
          final file = File('$path/${show.filename}');

          if (await file.exists()) {
            //delete the file
            try {
              final file = File('$path/${show.filename}');
              file.delete();
              debugPrint('deleting file');
              downloadedBox.put(show.id, false);
            } catch (e) {
              debugPrint('had an error deleting the file');
              // return false;
            }
          } else {
            //If file not on the device, check if we have internet connection
            //check if connected:
            bool connected = await shows.connectivityCheck ?? false;
            //check if file exists
            List<String> showExists = await shows.checkShows(show);
            //If not connected, just stop.
            if (!context.mounted) return;
            if (!connected) {
              //No connection; show the no internet message and stop
              shows.snackbarMessageNoInternet(context);
            } else if (connected && showExists.isNotEmpty) {
              //We're connected but teh show isn't there
              shows.snackbarMessageError(context);
            } else if (connected && showExists.isEmpty) {
              //download the file
              debugPrint(
                  'The file seems to not be there - starting downloading process');
              //The user can choose to not be warned of download size, that is stored in downloadsApproved
              if (pref.downloadsApproved ?? false) {
                //downloading is approved - just download the file.
                downloadFile(path, shows.urlBase, show);
              } else {
                //if downloading is not already approved, get feedback from the user
                //I have
                if (!context.mounted) return;
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      //first get the size of the download so as to pass to the dialog
                      return FutureBuilder(
                          future: getDownloadSize(url),
                          builder: (ctx, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else {
                              return DownloadConfirmation(
                                  url, snapshot.data.toString());
                            }
                          });
                    }).then((responseFromDialog) async {
                  //if response is true, download. If not, nothing happens.
                  if (responseFromDialog) {
                    downloadFile(path, urlbase, show);
                  }
                });
              }
            } else {
              //We should have covered our bases here but
              shows.snackbarMessageNoInternet(context);
            } // end of else
          }
        } catch (e) {
          debugPrint('had an error checking if the file was there or not');
          debugPrint(e.toString());
        }
      }
    }

    Widget iconStack() {
      return Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 4,
            //This sets to show the percentage done of the download if downloading
            //and an indicator either downloaded or not downloaded.
            value: _isDownloading ? _percentDone : 0,
          ),
          if (widget.showArrow)
            IconButton(
                iconSize: widget.iconSize,
                icon: _isDownloaded
                    ? Icon(
                        Icons.download_done_sharp,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : Icon(
                        Icons.download_sharp,
                        color: Theme.of(context).iconTheme.color,
                      ),
                onPressed: () {
                  //NB 'url' is the whole url you need to download the file
                  // String url = shows.urlBase +
                  //     '/' +
                  //     widget.show.urlSnip +
                  //     '/' +
                  //     widget.show.filename;
                  downloadOrDeleteFile(shows.urlBase, widget.show);
                  // setState(() {});
                }),
        ],
        // ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        if (widget.autoDownload) {
          if (_isDownloading) return;
          final directory = await getApplicationDocumentsDirectory();
          final path = directory.path;
          downloadFile(path, shows.urlBase, widget.show);
        }
      },
    );

    //Here is the main build that triggers everything.

    return ValueListenableBuilder<Box>(
        valueListenable: downloadedBox.listenable(keys: [widget.show.id]),
        builder: (context, val, _) {
          _isDownloaded = downloadedBox.get(widget.show.id) ?? false;
          return iconStack();
        });
  }
}

//------------------------------------------------
class DownloadConfirmation extends StatefulWidget {
  final String url;
  final String? downloadSize;

  const DownloadConfirmation(this.url, this.downloadSize, {super.key});

  @override
  State<DownloadConfirmation> createState() => _DownloadConfirmationState();
}

class _DownloadConfirmationState extends State<DownloadConfirmation> {
  bool? approved;

  @override
  void initState() {
    approved =
        Provider.of<ThemeModel>(context, listen: false).downloadsApproved;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pref = Provider.of<ThemeModel>(context, listen: false);

    return AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.downloadTitle,
      ),
      content: Text(
        '${AppLocalizations.of(context)!.downloadMessage}${widget.downloadSize ?? '?'} Mb?',
      ),

      actions: [
        Column(
          children: [
            SizedBox(
              width: 300,
              child: CheckboxListTile(
                title: Text(AppLocalizations.of(context)!.approveDownloads),
                value: approved,
                onChanged: (response) {
                  if (response == null) return;
                  if (response) {
                    pref.approveDownloading();
                  } else {
                    pref.denyDownloading();
                  }
                  setState(() {
                    approved = response;
                  });
                },
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    child: Text(AppLocalizations.of(context)!.settingsOK),
                    onPressed: () {
                      Navigator.pop(context, true);
                    }),
                TextButton(
                    child: Text(AppLocalizations.of(context)!.cancel),
                    onPressed: () {
                      Navigator.pop(context, false);
                    }),
              ],
            ),
          ],
        ),
      ],
      // ),
    );
  }
}
