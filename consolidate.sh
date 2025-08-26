#!/bin/sh

MAIN_DIR="$HOME/media/Students-Home"

for CLASS_DIR in $MAIN_DIR/*
do
	for STUDENT_DIR in $CLASS_DIR/*
	do
		STUDENT_NAME=${STUDENT_DIR##*/}
		chown GYEIS\\$STUDENT_NAME -R $STUDENT_DIR
	done
done

