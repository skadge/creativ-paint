import QtQuick 2.0
import QtQuick.Window 2.2

Drawer {
    id: colorpicker

    handle.right: drawerContainer.right
    handle.top: drawerContainer.bottom

    icon: "round-color_lens-24px.svg"

    signal colorUpdated

    property int colorPickerCols: 12

    property var colors: ["#fce94f",
        "#ee7308",
        "#7a613c",
        "#73d216",
        "#5485c4",
        "#6f3ac1",
        "#e388f3",
        "#ef2929",
        "#eeeeec",
        "#2e3436"]


    property alias paintbrushColor: colorGrid.color

    Rectangle {
        id: drawerContainer
        color: "#b2dfdb"

        height: childrenRect.height
        width: Screen.width

        Grid {
            anchors.right: parent.right
            id: colorGrid
            layoutDirection: Qt.LeftToRight

            property color color: "white"

            columns: colorPickerCols

            Component.onCompleted: {
                createColors();
            }

            function uniqueSelect(sampler) {
                for (var i = 0; i < children.length; i++) {
                    children[i].selected = false;
                }
                sampler.selected=true;
                var isNewColor = false;
                if (color !== sampler.color) isNewColor = true;

                color = sampler.color;
                if(isNewColor) {
                    parent.parent.colorUpdated();
                }
            }

            function selectColorAndClose(sampler) {
                uniqueSelect(sampler);
                parent.parent.close();
            }

            function createColors() {

                var sampler;
                for (var i = 0; i < colors.length; i++) {
                    var component = Qt.createComponent("ColorSample.qml");
                    sampler = component.createObject(colorGrid, {"color": colors[i]});

                    sampler.tapped.connect(selectColorAndClose);
                }
                uniqueSelect(sampler);


            }
        }
    }

}
