import QtQuick 2.0
import QtQuick.Window 2.2

Drawer {
    id: colorpicker

    handle.left: left
    handle.top: drawerContainer.bottom

    icon: "round-color_lens-24px.svg"

    signal colorUpdated

    onColorUpdated: close()

    property int colorPickerCols: 8

    property var colors: ["#fce94f",
            "#fcaf3e",
            "#73d216",
            "#2e3436",
            "#3465a4",
            "#ad7fa8",
            "#ef2929",
            "#eeeeec"]


    property alias color: colorGrid.color

    Rectangle {
        id: drawerContainer
        color: "#b2dfdb"

        height: childrenRect.height
        width: Screen.width

    Grid {
            id: colorGrid

            property color color: {
                    for (var i = 0; i < children.length; i++)
                            if(children[i].selected)
                                    return children[i].color;

                    return "black";
            }

            columns: colorPickerCols

            Component.onCompleted: createColors();


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
                    }


            }
    }
    }

}
