import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.kquickcontrols as KQuickControls

Kirigami.FormLayout {
	id: page

	property alias cfg_command: commandField.text
	property alias cfg_refreshIntervalMs: refreshInterval.value
	property alias cfg_refreshWhenCollapsed: refreshWhenCollapsed.checked
	property alias cfg_allowSelection: allowSelection.checked
	property alias cfg_fontPixelSize: fontSize.value
	property alias cfg_useSystemColors: useSystemColors.checked
	property alias cfg_foregroundColor: foregroundColorButton.color
	property alias cfg_backgroundColor: backgroundColorButton.color
	property alias cfg_transparentBackground: transparentBackground.checked
	property alias cfg_backgroundOpacity: backgroundOpacity.value

	Kirigami.Separator {
		Kirigami.FormData.label: "General"
		Kirigami.FormData.isSection: true
	}

	PlasmaComponents.TextField {
		id: commandField
		Kirigami.FormData.label: "Command:"
		placeholderText: "fastfetch --pipe false"
		Layout.minimumWidth: Kirigami.Units.gridUnit * 16
	}

	PlasmaComponents.SpinBox {
		id: refreshInterval
		Kirigami.FormData.label: "Refresh interval:"
		from: 250
		to: 60000
		stepSize: 250
		textFromValue: function(value) { return value + " ms" }
		valueFromText: function(text) { return parseInt(text) }
	}

	PlasmaComponents.SpinBox {
		id: fontSize
		Kirigami.FormData.label: "Font size:"
		from: 7
		to: 16
		textFromValue: function(value) { return value + " px" }
		valueFromText: function(text) { return parseInt(text) }
	}

	PlasmaComponents.CheckBox {
		id: refreshWhenCollapsed
		Kirigami.FormData.label: "Behavior:"
		text: "Keep refreshing while collapsed"
	}

	PlasmaComponents.CheckBox {
		id: allowSelection
		text: "Allow selecting and copying output"
	}

	Kirigami.Separator {
		Kirigami.FormData.label: "Appearance"
		Kirigami.FormData.isSection: true
	}

	PlasmaComponents.CheckBox {
		id: useSystemColors
		Kirigami.FormData.label: "Colors:"
		text: "Use system theme colors"
	}

	KQuickControls.ColorButton {
		id: foregroundColorButton
		Kirigami.FormData.label: "Foreground:"
		showAlphaChannel: false
		enabled: !useSystemColors.checked
	}

	KQuickControls.ColorButton {
		id: backgroundColorButton
		Kirigami.FormData.label: "Background:"
		showAlphaChannel: false
		enabled: !useSystemColors.checked && !transparentBackground.checked
	}

	PlasmaComponents.CheckBox {
		id: transparentBackground
		text: "Transparent background"
	}

	RowLayout {
		Kirigami.FormData.label: "Opacity:"
		enabled: !transparentBackground.checked
		spacing: Kirigami.Units.smallSpacing

		PlasmaComponents.Slider {
			id: backgroundOpacity
			from: 0.0
			to: 1.0
			stepSize: 0.05
			Layout.fillWidth: true
			Layout.minimumWidth: Kirigami.Units.gridUnit * 10
		}

		PlasmaComponents.Label {
			text: Math.round(backgroundOpacity.value * 100) + "%"
			horizontalAlignment: Text.AlignRight
			Layout.minimumWidth: Kirigami.Units.gridUnit * 2.5
		}
	}
}
