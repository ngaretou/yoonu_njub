// import 'dart:math';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

import '../providers/shows.dart';
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
  @override
  void initState() {
    _isDownloading = false;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  var _percentDone;

  @override
  Widget build(BuildContext context) {
    final shows = Provider.of<Shows>(context, listen: false);

    Future<void> _downloadOrDeleteFile(String url, String filename) async {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;

      try {
        final file = File('$path/$filename');

        if (await file.exists()) {
          //delete the file
          print('The file is on the device');

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
          if (!(await shows.connectivityCheck)) {
            //No connection; show the no internet message and stop
            shows.snackbarMessageNoInternet(context);
          } else {
            //download the file
            print('The file seems to not be there - downloading');

            setState(() {
              _isDownloading = true;
            });

            String dir = (await getApplicationDocumentsDirectory()).path;
            File file = new File('$dir/$filename');
            print('$url');

            //Get the file
            var request = await http.get('$url');
            print(request.contentLength);
            var bytes = request.bodyBytes; //close();
            await file.writeAsBytes(bytes);
            print(file.path);
            print('download done');
            setState(() {
              _isDownloading = false;
              _isDownloaded = true;
            });
            //original download - not working
            // http.StreamedResponse _response;
            // List<int> _bytes = [];

            // _response = await http.Client()
            //     .send(http.Request('GET', Uri.parse("$url/$filename")));
            // // final _total = _response.contentLength;
            // _response.stream.listen((value) {
            //   //If the server supports telling us the contentLength this works, but the server we are working with at the moment does not.
            //   //Leaving this here for reference or for future use.
            //   //https://medium.com/flutter-community/how-to-show-download-progress-in-a-flutter-app-8810e294acbd
            //   // setState(() {
            //   _bytes.addAll(value);
            //   //   _received += value.length;
            //   //   _percentDone = (_received / _total);

            //   // });
            // }).onDone(() async {
            //   final file = File(
            //       "${(await getApplicationDocumentsDirectory()).path}/$filename");
            //   await file.writeAsBytes(_bytes);
            //   print('download done');
            //   setState(() {
            //     _isDownloading = false;
            //     _isDownloaded = true;
            //   });
            // });
          }
        }
      } catch (e) {
        print('had an error checking if the file was there or not');
      }
    }

    return FutureBuilder(
        future: shows.localAudioFileCheck(widget.show.filename),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            _isDownloaded = snapshot.data;
            return Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 4,
                  //This is set up to show percentage - but as the server we have does not give us contentLength leaving as is -
                  //If _isDownloading is true, it shows _percentDone, which is null, which gives you spinning.
                  //0 hides the CircularProgressIndicator :)
                  value: _isDownloading ? _percentDone : 0,
                ),
                IconButton(
                    icon: _isDownloaded
                        ? Icon(
                            Icons.download_sharp,
                            color: Theme.of(context).accentColor,
                          )
                        : Icon(
                            Icons.download_sharp,
                            color: Theme.of(context).iconTheme.color,
                          ),
                    onPressed: () {
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
        });
  }
}
