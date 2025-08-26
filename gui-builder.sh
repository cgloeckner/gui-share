#!/bin/bash

APP_NAME="gui-share"
APP_DATA="$HOME/media/$USER (H:)/.gui-share"
COURSE_ROOT="$APP_DATA/Kurse"
CLASSES_PATH="$HOME/media/Students-Home"

# Listet enthaltene Ordner (inkl. Symlinks auf Ordner)
# @param $1 Pfad des Ordners
# @param $2 Präfix für aufzulistende Elemente (z.B. "foo/")
# @return String mit Elementen, separiert durch '\n'
list_subdirs() {
	local parent="$1"
	local prefix="$2"
	local result=""

	for subdir in "$parent"/*/; do
		[ -d "$subdir" ] || continue
		result+="$prefix$(basename "$subdir")"$'\n'
	done
	
	printf '%s' "$result"
}

# Zeigt Auswahl-Liste für Mehrfachauswahl an
# @param $1 String mit Elementen, separiert durch '\n'
# @return String mit ausgewählten Elementen, separiert durch '\n'
choose_multiple_targets() {
	local items="$1"
	for item in $items; do
		line="FALSE $item"
		zenity_data+="$line"$'\n'
	done

	zenity --list \
		--checklist \
		--title="$2" \
		--column="" \
		--column="Mehrfachauswahl" \
		--height=400 \
		--width=200 \
		--separator=$'\n' \
		$zenity_data
}

# Kursname erfassen
COURSE_NAME=`zenity --entry --title="Kurs anlegen" --text="Kursname"`
if [ -z "$COURSE_NAME" ]; then
	zenity --notification --text="Kurserstellung durch Benutzer abgebrochen"
	exit 0
fi
COURSE_PATH="$COURSE_ROOT/$COURSE_NAME"
mkdir -p "$COURSE_PATH"

# relevante Klasse(n) auswählen
zenity --info --text="Bitte Klassen und anschließend Schüler wählen, um einen Kurs zusammenzustellen."
CLASSES_LIST=$(list_subdirs "$CLASSES_PATH" "")
CLASS_NAMES=$(choose_multiple_targets "$CLASSES_LIST" "Auswahl Klassen")
if [ -z "$CLASS_NAMES" ]; then
	zenity --notification --text="Kurserstellung durch Benutzer abgebrochen"
	exit 0
fi

for TAG in $CLASS_NAMES; do
	# relevante Schüler auswählen
	CLASS_PATH="$CLASSES_PATH/$TAG"
	STUDENTS_LIST=$(list_subdirs "$CLASS_PATH" "")
	STUDENTS_NAMES=$(choose_multiple_targets "$STUDENTS_LIST" "Auswahl Schüler $TAG")
	
	# Symlinks im Kurs-Ordner anlegen
	for NAME in $STUDENTS_NAMES; do
		SRC_PATH="$CLASS_PATH/$NAME"
		SYM_PATH="$COURSE_PATH/$NAME"
		ln -s "$SRC_PATH" "$SYM_PATH"
	done
done

zenity --notification --text="Kurs '$COURSE_NAME' wurde erstellt"
xdg-open "$COURSE_PATH"

