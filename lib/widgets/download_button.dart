// @dart=2.9

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/shows.dart';
import '../providers/theme.dart';
// import 'package:just_audio/just_audio.dart';

class DownloadButton extends StatefulWidget {
  final Show show;
  DownloadButton(this.show);

  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool _isDownloaded;
  bool _isDownloading;
  double _percentDone;
  bool approved;

  @override
  void initState() {
    _isDownloading = false;
    super.initState();
  }

  //path is the local app Document path; url is the WHOLE url you need to download, filename is just the filename
  Future downloadFile(String path, String url, String filename) async {
    //here we set the flag to true so we don't restart the process
    setState(() {
      _isDownloading = true;
    });
    //This will hold the downloaded file temporarily before writing
    List<int> _bytes = [];

    final http.StreamedResponse _response =
        await http.Client().send(http.Request('GET', Uri.parse("$url")));
    //total size of download
    final _total = _response.contentLength;

    var _received = 0;
    //Here we listen to the stream an monitor it so we nkow how much has been downloaded, which allows us to calculate the percentage done
    //https://medium.com/flutter-community/how-to-show-download-progress-in-a-flutter-app-8810e294acbd
    _response.stream.listen((value) {
      setState(() {
        _bytes.addAll(value);
        _received += value.length;
        _percentDone = ((_received) / _total);
      });
    }, onDone: () async {
      final file = File("$path/$filename");
      await file.writeAsBytes(_bytes);
      print('download done');
      setState(() {
        _isDownloading = false;
        _isDownloaded = true;
      });
    }, onError: (e) {
      print('had an error checking if the file was there or not');
      print(e);
    }, cancelOnError: true);
  }

  @override
  Widget build(BuildContext context) {
    final shows = Provider.of<Shows>(context, listen: false);
    final pref = Provider.of<ThemeModel>(context, listen: false);

    Future<String> getDownloadSize(url) async {
      // if (downloadSizeGotten) {
      //   return _totalFormatted;
      // } else {
      //download request
      final http.Response r = await http.head(Uri.parse(url));
      final _total = r.headers["content-length"];
      final _totalAsInt = double.parse(_total);
      final String _totalFormatted = (_totalAsInt / 1000000).toStringAsFixed(2);

      // downloadSizeGotten = true;
      return _totalFormatted;
    }

    //This either deletes the file if it's on the device or downloads it if not.
    Future<void> _downloadOrDeleteFile(String url, String filename) async {
      //If you are not already downloading something...
      if (!_isDownloading) {
        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path;
        print(directory.path);
        //see if it's on the device
        try {
          final file = File('$path/$filename');

          if (await file.exists()) {
            //delete the file
            try {
              final file = File('$path/$filename');
              file.delete();
              print('deleting file');
              setState(() {
                _isDownloaded = false;
              });
            } catch (e) {
              print('had an error checking if the file was there or not');
              return false;
            }
          } else {
            //If file not on the device, check if we have internet connection
            if (!(await shows.connectivityCheck)) {
              //No connection; show the no internet message and stop
              shows.snackbarMessageNoInternet(context);
            } else {
              //download the file
              print(
                  'The file seems to not be there - starting downloading process');
              //The user can choose to not be warned of download size, that is stored in downloadsApproved
              if (pref.downloadsApproved) {
                //downloading is approved - just download the file.
                downloadFile(path, url, filename);
              } else {
                //if downloading is not already approved, get feedback from the user
                //I have
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
                              return DownloadConfirmation(url, snapshot.data);
                            }
                          });
                    }).then((responseFromDialog) async {
                  //if response is true, download. If not, nothing happens.
                  if (responseFromDialog) {
                    downloadFile(path, url, filename);
                  }
                });
              }
            }
          } // end of else

        } catch (e) {
          print('had an error checking if the file was there or not');
          print(e);
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
          IconButton(
              icon: _isDownloaded
                  ? Icon(
                      Icons.download_sharp,
                      color: Theme.of(context).colorScheme.secondary,
                    )
                  : Icon(
                      Icons.download_sharp,
                      color: Theme.of(context).iconTheme.color,
                    ),
              onPressed: () {
                //NB 'url' is the whole url you need to download the file
                String url = shows.urlBase +
                    '/' +
                    widget.show.urlSnip +
                    '/' +
                    widget.show.filename;
                _downloadOrDeleteFile(url, widget.show.filename);
                // setState(() {});
              }),
        ],
        // ),
      );
    }

    //Here is the main build that triggers everything.

    return _isDownloading
        //If downloading you don't need to check if the file is there or not
        ? iconStack()
        //If first run on the page you check to see if the file is local
        : FutureBuilder(
            future: shows.localAudioFileCheck(widget.show.filename),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return
                    // Center(
                    //     child: Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 14.5),
                    //   child:
                    Icon(
                  Icons.download_sharp,
                  color: Theme.of(context).iconTheme.color,
                )
                    // ))
                    ;
              } else {
                //set the _isDownloaded flag to true or false depending on the result of the above future, localAudioFileCheck, in shows.dart
                _isDownloaded = snapshot.data;
                return iconStack();
              }
            });
  }
}

//------------------------------------------------
class DownloadConfirmation extends StatefulWidget {
  final String url;
  final String downloadSize;

  DownloadConfirmation(this.url, this.downloadSize);

  @override
  _DownloadConfirmationState createState() => _DownloadConfirmationState();
}

class _DownloadConfirmationState extends State<DownloadConfirmation> {
  bool approved;

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
        AppLocalizations.of(context).downloadTitle,
      ),
      content: Text(
        AppLocalizations.of(context).downloadMessage +
            widget.downloadSize +
            ' Mb?',
      ),

      actions: [
        Column(
          children: [
            Container(
              width: 300,
              child: CheckboxListTile(
                title: Text(AppLocalizations.of(context).approveDownloads),
                value: approved,
                onChanged: (response) {
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
                    child: Text(AppLocalizations.of(context).settingsOK),
                    onPressed: () {
                      Navigator.pop(context, true);
                    }),
                TextButton(
                    child: Text(AppLocalizations.of(context).cancel),
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
