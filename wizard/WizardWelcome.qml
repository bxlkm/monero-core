// Copyright (c) 2014-2015, The Monero Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.2
import QtQuick.XmlListModel 2.0
import QtQuick.Layouts 1.1
import QtQml 2.2


Item {
    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }

    QtObject {
        id: d
        readonly property string daemonAddressTestnet : "localhost:38018";
        readonly property string daemonAddressMainnet : "localhost:18018";
    }

    onOpacityChanged: visible = opacity !== 0



    function onPageClosed(settingsObject) {
        var lang = languagesModel.get(gridView.currentIndex);
        settingsObject['language'] = lang.display_name;
        settingsObject['wallet_language'] = lang.wallet_language;
        settingsObject['locale'] = lang.locale;
        return true
    }

    // Welcome text
    Column {
        id: headerColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 74
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 24

        Text {
            id: welcomeText
            anchors.left: parent.left
            anchors.right: parent.right
            font.family: "Arial"
            font.pixelSize: 28
            //renderType: Text.NativeRendering
            color: "#3F3F3F"
            wrapMode: Text.Wrap
            // hack to implement dynamic translation
            // https://wiki.qt.io/How_to_do_dynamic_translation_in_QML
            text: qsTr("Welcome") /*+
                  translationManager.emptyString*/
        }

        Text {
            id: selectLanguageText
            anchors.left: parent.left
            anchors.right: parent.right
            font.family: "Arial"
            font.pixelSize: 18
            //renderType: Text.NativeRendering
            color: "#4A4646"
            wrapMode: Text.Wrap
            text: qsTr("Please choose a language and regional format.")
//                  + translationManager.emptyString
        }
    }
    // Flags model
    XmlListModel {
        id: languagesModel
        source: "/lang/languages.xml"
        query: "/languages/language"

        XmlRole { name: "display_name"; query: "@display_name/string()" }
        XmlRole { name: "locale"; query: "@locale/string()" }
        XmlRole { name: "wallet_language"; query: "@wallet_language/string()" }
        XmlRole { name: "flag"; query: "@flag/string()" }
        // TODO: XmlListModel is read only, we should store current language somewhere else
        // and set current language accordingly
        XmlRole { name: "isCurrent"; query: "@enabled/string()" }


    }

    // Flags view
    GridView {
        id: gridView
        cellWidth: 140
        cellHeight: 120
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: headerColumn.bottom
        anchors.topMargin: 24
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        clip: true
        model: languagesModel

        delegate: Item {
            id: flagDelegate
            width: gridView.cellWidth
            height: gridView.cellHeight

            Rectangle {
                id: flagRect
                width: 60; height: 60
                anchors.centerIn: parent
                radius: 30
                color: gridView.currentIndex === index ? "#DBDBDB" : "#FFFFFF"
                Image {
                    anchors.fill: parent
                    source: flag
                }
            }

            Text {
                font.family: "Arial"
                font.pixelSize: 24
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: flagRect.bottom
                anchors.topMargin: 10
                font.bold: gridView.currentIndex === index
                elide: Text.ElideRight
                color: "#3F3F3F"
                text: display_name
            }
            MouseArea {
                id: delegateArea
                anchors.fill: parent
                onClicked:  {
                    gridView.currentIndex = index
                    var data = languagesModel.get(gridView.currentIndex);
                    if (data !== null || data !== undefined) {
                        var locale = data.locale
                        translationManager.setLanguage(locale.split("_")[0]);
                        wizard.switchPage(true)
                    }
                }
            }
        } // delegate


    }


}
