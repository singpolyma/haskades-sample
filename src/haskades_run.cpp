/* Copyright (c) 2012 Research In Motion Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <QtDebug>
#include <QLocale>
#include <QTranslator>
#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/Page>

QEvent::Type customSignalEventType;
#define CUSTOM_SIGNAL_clockTick 1

class CustomSignalEvent : public QEvent {

public:
	CustomSignalEvent(int signalEvent, QString str0) : QEvent(customSignalEventType) {
		this->signalEvent = signalEvent;
		this->str0 = str0;
	}

	int signalEvent;
	QString str0;
};

class AppWrapper: public QObject {
Q_OBJECT

public:
	// This is our constructor that sets up the recipe.
	AppWrapper(QString qml_path, void (*_mkFile)(const char *arg0)) {
		this->_mkFile = _mkFile;

		// Obtain a QMLDocument and load it into the qml variable, using build patterns.
		bb::cascades::QmlDocument *qml = bb::cascades::QmlDocument::create(qml_path);

		// If the QML document is valid, we process it.
		if(!qml->hasErrors()) {
			qml->setContextProperty("app", this);

			// Create the application Page from QMLDocument.
			bb::cascades::Page *appPage = qml->createRootObject<bb::cascades::Page>();

			if (appPage) {
				// Set the main scene for the application to the Page.
				bb::cascades::Application::instance()->setScene(appPage);
			}
		} else {
			qCritical() << qml->errors();
		}
	}

	virtual bool event(QEvent *e) {
		if(e->type() == customSignalEventType) {
			CustomSignalEvent *ev = (CustomSignalEvent*)e;
			switch(ev->signalEvent) {
				case CUSTOM_SIGNAL_clockTick:
					emit clockTick(ev->str0);
					return true;
					break;
			}
			return false;
		} else {
			return QObject::event(e);
		}
	}

public slots:
	Q_INVOKABLE void mkFile(QString arg0) {
		_mkFile(arg0.toUtf8().constData());
	}

signals:
	void clockTick(QString);

protected:
	void (*_mkFile)(const char *arg0);
};

extern "C" {

QObject *mainAppGlobal;

void emit_CustomSignalEvent(int signalEvent, const char *str0) {
	QEvent *e = (QEvent *)new CustomSignalEvent(signalEvent, QString::fromUtf8(str0));
	QCoreApplication::postEvent(mainAppGlobal, e);
}

int haskades_run(char *qml_path, void (*_mkFile)(const char *arg0)) {
	int argc = 0;
	char *argv[] = { NULL };
	// Instantiate the main application constructor.
	bb::cascades::Application app(argc, argv);

	// Set up the translator.
	QTranslator translator;
	QString locale_string = QLocale().name();
	QString filename = QString("sample_%1").arg(locale_string); // TODO
	if (translator.load(filename, "app/native/qm")) {
		app.installTranslator(&translator);
	}

	customSignalEventType = (QEvent::Type)QEvent::registerEventType();

	// Initialize our application.
	AppWrapper mainApp(QString::fromUtf8(qml_path), _mkFile);
	mainAppGlobal = (QObject*)&mainApp;

	// We complete the transaction started in the main application constructor and start the
	// client event loop here. When loop is exited the Application deletes the scene which
	// deletes all its children.
	return bb::cascades::Application::exec();
}

}

// Tell MOC to run on this file
#include "haskades_run.moc"
