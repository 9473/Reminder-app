APP_NAME=MotivateBar

.PHONY: build package install run clean

build:
	swift build

package:
	./Scripts/package_app.sh

install:
	./Scripts/install.sh

run:
	swift run

clean:
	rm -rf .build dist
