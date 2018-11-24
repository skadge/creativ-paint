import QtQuick 2.0
import QtQuick.Window 2.2

Drawer {
    id: colorpicker

    handle.left: left
    handle.top: drawerContainer.bottom

    icon: "round-color_lens-24px.svg"

    signal colorUpdated

    onColorUpdated: close()

    property int colorPickerCols: 12

    property var colors: ["#fce94f",
            "#ee7308",
            "#7a613c",
            "#73d216",
            "#3465a4",
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
            id: colorGrid
            layoutDirection: Qt.RightToLeft

            property color color: {
                    for (var i = 0; i < children.length; i++)
                            if(children[i].selected)
                                    return children[i].color;

                    return "transparent";
            }

            columns: colorPickerCols

            Component.onCompleted: createColors();

            Button {
                icon: "eraser-solid.svg"
                onTapped: {
                    colorpicker.close();
                    selected=true;
                    for (var i = 0; i < colorGrid.children.length; i++) {
                            colorGrid.children[i].selected = false;
                    }
                }
            }


            function uniqueSelect(sampler) {
                    for (var i = 0; i < children.length; i++) {
                            children[i].selected = false;
                    }
                    sampler.selected=true;
                    parent.parent.colorUpdated();
            }

            function createColors() {

                    var sampler;
                    for (var i = 0; i < colors.length; i++) {
                            var component = Qt.createComponent("ColorSample.qml");
                            sampler = component.createObject(colorGrid, {"color": colors[i]});

                            sampler.tapped.connect(uniqueSelect);
                            uniqueSelect(sampler);
                    }


            }
    }
    }

}
