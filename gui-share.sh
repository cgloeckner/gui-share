#!/bin/bash

APP_NAME="gui-share"
CLASSES_PATH="$HOME/media/Students-Home"
APP_DATA="$HOME/media/$USER (H:)/.gui-share"
SRC_PATH="$APP_DATA/Austeilen"
COURSE_PATH="$APP_DATA/Kurse"

# Listet enthaltene Ordner (inkl. Symlinks auf Ordner)
# @param $1 Pfad des Ordners
# @param $2 Präfix für aufzulistende Elemente (z.B. "foo/")
# @return String mit Elementen, separiert durch '\n'
list_subdirs() {
	local parent="$1"
	local prefix="$2"
	local result=""

	for subdir in "$parent"/*/; do
		if [ -L "$subdir" ]; then
			subdir=$(readlink -f "$subdir")
		fi
		[ -d "$subdir" ] || continue
		result+="$prefix$(basename "$subdir")"$'\n'
	done
	
	printf '%s' "$result"
}

# Zeigt Auswahl-Liste an
# @param $1 String mit Elementen, separiert durch '\n'
# @return String mit ausgewähltem Element
choose_target() {
	echo -e "$1" | zenity --list \
		--title="$2" \
		--column="$2:" \
		--height=400 \
		--width=200
}

# Kopiert Dateien aus $SRC_PATH an mehrere Ziele und zeigt Progress-Bar
# @param $1 String mit Zielpfaden, separiert durch '\n'
copy_files() {
	local TARGET_PATHS="$1"
	
	local total=$(echo "$TARGET_PATHS" | wc -l)
	local count=0
	
	(
	while IFS= read -r DST_PATH; do
		cp -r "$SRC_PATH/." "$DST_PATH"
		
		rel_target=$(basename "$(dirname "$DST_PATH")")/$(basename "$DST_PATH")
		
		count=$((count+1))
		percent=$((count * 100 / total))
		echo "$percent"
		echo "# Kopiere nach $rel_target"
		sleep 0.05
	done <<< "$TARGET_PATHS"
	) |
	zenity --progress \
		--title="Kopiere Dateien" \
		--text="Bitte warten..." \
		--percentage=0 \
		--width=400 \
		--auto-close
}

# Aufforderung zum Kopieren ins Austeilen-Verzeichnis
mkdir -p "$SRC_PATH"
xdg-open "$SRC_PATH"
zenity --info --text="Bitte auszuteilende Dateien und Ordner im Austeilen-Ordner ablegen und Ok drücken."

# Auswahl der Ziel-Klasse
CLASSES_LIST=$(list_subdirs "$CLASSES_PATH" "")
if [ -z "$CLASSES_LIST" ]; then
	zenity --error --text="Klassen-Verzeichnis nicht gefunden"
	exit 1
fi
CLASSES_LIST+='\n'$(list_subdirs "$COURSE_PATH" "")
CLASS_NAME=$(choose_target "$CLASSES_LIST" "Austeilen an")
if [ -z "$CLASS_NAME" ]; then
	zenity --notification --text="Austeilen durch Benutzer abgebrochen"
	exit 0
fi

# Schüler-Verzeichnisse erfassen
STUDENTS_PATH="$CLASSES_PATH/$CLASS_NAME"
if [ ! -d "$STUDENTS_PATH" ]; then
	# Kurs-Verzeichnis nutzen
	STUDENTS_PATH="$COURSE_PATH/$CLASS_NAME"
fi
ABS_PATHS=$(list_subdirs "$STUDENTS_PATH" "$STUDENTS_PATH/")

# Kopiervorgang starten
copy_files "$ABS_PATHS"
zenity --notification --text="Austeilen beendet"

