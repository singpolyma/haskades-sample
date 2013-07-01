import bb.cascades 1.0

Page {
	onCreationCompleted: {
		app.ClockTick.connect(function(t) {clockText.text = t;});
	}

	Container {
		layout: DockLayout {
		}

		// The container containing the bubble image and text
		Container {
			// This container is also using a dock layout and it is centered on the
			// background image by setting up the layoutProperties for the container.
			horizontalAlignment: HorizontalAlignment.Center
			verticalAlignment: VerticalAlignment.Center
			layout: DockLayout {
			}

			// The bubble image
			ImageView {
				imageSource: "asset:///images/bubble.png"
			}

			// A text label with a clock in it
			Label {
				id: clockText

				// Set the label text, by using qsTr() the string can be translated.
				text: qsTr("Initializing...")

				// The Label text style defined in the attachedObjects below
				textStyle.base: clockStyle.style

				// Center the text in the container.
				verticalAlignment: VerticalAlignment.Center
				horizontalAlignment: HorizontalAlignment.Center
			}

			// This button just sort of jammed in here to show we can call
			// Haskell code from here
			Button {
				id: someButton
				text: "Write a file to /tmp/lol"
				onClicked: {
					app.MkFile("/tmp/lol");
				}
			}
		}
	}

	attachedObjects: [
		// Non UI objects are specified as attached objects
		TextStyleDefinition {
			id: clockStyle
			base: SystemDefaults.TextStyles.BigText
			fontWeight: FontWeight.Bold
			color: Color.create("#ff5D5D5D")
		}
	]
}
