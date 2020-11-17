import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../locale/app_localization.dart';

class AboutScreen extends StatelessWidget {
  static const routeName = 'about-screen';

  TextSpan urlGo(String text, String url, linkTheme) {
    return TextSpan(
        text: text,
        style: linkTheme,
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle linkTheme = Theme.of(context)
        .textTheme
        .subtitle1
        .copyWith(decoration: TextDecoration.underline);
    TextStyle defaultStyle = Theme.of(context).textTheme.subtitle1;
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalization.of(context).settingsAbout,
              style: Theme.of(context).textTheme.headline6),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20),
          child: ListView(children: [
            RichText(
                text: TextSpan(style: defaultStyle, children: [
              TextSpan(
                  text: 'Yoonu Njub',
                  style: Theme.of(context).textTheme.headline6),
            ])),
            Divider(
              thickness: 3,
            ),
            RichText(
                text: TextSpan(style: defaultStyle, children: [
              TextSpan(
                  text: 'Yoonu Njub',
                  style: TextStyle(fontStyle: FontStyle.italic)),
              TextSpan(
                  text:
                      ' © 1998 Paul Bramsen.\n\nWolof Scriptures quoted by permission.\n\nThey consist of:\n\nThe Old Testament selections published under the name "Mucc gi Yàlla waajal" Copyright © 1999 ;\n\n\The full text of Genesis published under the name "Njalbéen ga: xaaj bi jëkk ci Tawreetu Musaa" Copyright © 2003;\n\nThe complete New Testament, published under the name "Kàddug Dëgg Gi" Copyright © 1987;\n\nThe complete New Testament, revised edition, published under the name "Téereb Injiil di Kàddug Yàlla" Copyright © 2004.\n\nThe copyright of the Wolof scriptures is held by:\n\nLes Assemblées Evangéliques du Sénégal and La Mission Baptiste du Sénégal.\n\nAll rights reserved. Used by permission.\n\n'),
              urlGo('YoonuNjub.org\n\n', 'http://http://yoonunjub.org/',
                  linkTheme),
              urlGo('Wolof Bible online', 'http://biblewolof.com', linkTheme),
            ])),
            Divider(
              thickness: 3,
            ),
            RichText(
                text: TextSpan(style: defaultStyle, children: [
              TextSpan(
                  text: 'Thanks:\n\n',
                  style: Theme.of(context).textTheme.headline6),
              TextSpan(
                  text: 'Code:\n\n',
                  style: Theme.of(context).textTheme.subtitle2),
              urlGo('Thanks to Oliver Gomes for several great ideas.\n\n',
                  'https://github.com/oliver-gomes/', linkTheme),
              TextSpan(
                  text: 'Photos:\n\n',
                  style: Theme.of(context).textTheme.subtitle2),
              urlGo('Adrien Olichon\n\n', 'https://unsplash.com/@adrienolichon',
                  linkTheme),
              urlGo(
                  'Mike Ko\n\n', 'https://unsplash.com/@kocreated', linkTheme),
              urlGo('Augustine Wong\n\n', 'https://unsplash.com/@augustinewong',
                  linkTheme),
              urlGo('Annie Spratt\n\n', 'https://unsplash.com/@anniespratt',
                  linkTheme),
              urlGo('Chiranjeeb Mitra\n\n', 'https://unsplash.com/@chiro_007',
                  linkTheme),
              urlGo('Jeff Attaway\n\n',
                  'https://www.flickr.com/photos/attawayjl/', linkTheme),
              urlGo('Frank McKenna\n\n', 'https://unsplash.com/@frankiefoto',
                  linkTheme),
//
//<span>Photo by <a href="https://unsplash.com/@lionel_gustave?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Lionel Gustave</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>
//<span>Photo by <a href="https://unsplash.com/@vincegx?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Vince Gx</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>
//<span>Photo by <a href="https://unsplash.com/@frostroomhead?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Rodion Kutsaev</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>
//<span>Photo by <a href="https://unsplash.com/@nimri?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Fares Nimri</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>
//<span>Photo by <a href="https://unsplash.com/@kazuend?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">kazuend</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>
//<span>Photo by <a href="https://unsplash.com/@dynamicwang?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">DynamicWang</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>
//<span>Photo by <a href="https://unsplash.com/@airdeez?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">The AIRDEEz</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>
//<span>Photo by <a href="https://unsplash.com/@pictagramar?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Amar Yashlaha</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>
//<span>Photo by <a href="https://unsplash.com/@alicekat?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Alice Donovan Rouse</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>
//<span>Photo by <a href="https://unsplash.com/@kiprono_kitur?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Gabriel Kiprono</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>
//<span>Photo by <a href="https://unsplash.com/@duagram?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Julien Gaud</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>
//
//
//
//
//
//

//
//
//

//
//
//

//
//
//

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
            ])),
            Divider(
              thickness: 3,
            ),
            RichText(
                text: TextSpan(style: defaultStyle, children: [
              TextSpan(
                  text: 'Licenses:\n\n',
                  style: Theme.of(context).textTheme.subtitle2),
              TextSpan(text: 'MIT Licensed software included:\n\n'),
              urlGo('provider\nCopyright © 2019 Remi Rousselet\n\n',
                  'https://github.com/rrousselGit/provider', linkTheme),
              urlGo(
                  'just_audio\nCopyright (c) 2019-2020 Ryan Heise and the project contributors.\n\n',
                  'https://github.com/ryanheise/just_audio',
                  linkTheme),
              urlGo(
                  'audio_session\nCopyright (c) 2020 Ryan Heise and the project contributors.\n\n',
                  'https://github.com/ryanheise/audio_session\n\n',
                  linkTheme),
              urlGo(
                  'font_awesome_flutter\nCopyright (c) 2017 Brian Egan\n\n',
                  'https://github.com/fluttercommunity/font_awesome_flutter\n\n',
                  linkTheme),
              TextSpan(
                  text:
                      'MIT License:\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\n'),
            ])),
            Divider(
              thickness: 3,
            ),
            RichText(
              text: TextSpan(
                style: defaultStyle,
                children: [
                  TextSpan(text: 'BSD Licensed software included:\n\n'),
                  urlGo(
                      'shared_preferences\nCopyright 2017 The Chromium Authors. All rights reserved.\n\n',
                      'https://github.com/flutter/plugins/tree/master/packages/shared_preferences',
                      linkTheme),
                  urlGo(
                      'url_launcher\nCopyright 2017 The Chromium Authors. All rights reserved.\n\n',
                      'https://github.com/flutter/plugins/blob/master/packages/url_launcher',
                      linkTheme),
                  urlGo(
                      'flutter\nCopyright 2014, 2017, the Flutter project authors. All rights reserved.\n\n',
                      'https://github.com/flutter/flutter/',
                      linkTheme),
                  urlGo(
                      'share\nCopyright 2018 the Dart project authors, Inc. All rights reserved.\n\n',
                      'https://github.com/flutter/plugins/',
                      linkTheme),
                  urlGo(
                      'scrollable_positioned_list\nCopyright 2014, 2017, the Flutter project authors. All rights reserved.\n\n',
                      'https://github.com/google/flutter.widgets/',
                      linkTheme),
                  urlGo(
                      'connectivity\nCopyright 2017 The Chromium Authors. All rights reserved\n\n',
                      'https://github.com/flutter/plugins\n\n',
                      linkTheme),
                  urlGo(
                      'path_provider\Copyright 2017, the Flutter project authors. All rights reserved.\n\n',
                      'https://github.com/flutter/plugins\n\n',
                      linkTheme),
                  TextSpan(
                      text:
                          'Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n\n- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n\n- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\n\n- Neither the name of Google Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.\n\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.\n\n'),
                  TextSpan(
                      text: 'License:\n\n',
                      style: Theme.of(context).textTheme.headline6),
                  TextSpan(text: 'Yoonu Njub app code © 2020 SIM.\n\n'),
                  TextSpan(
                      text:
                          'MIT License:\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\n'),
                ],
              ),
            ),
          ]),
        ));
  }
}
