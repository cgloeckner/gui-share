# gui-share
an alternative file distribution tool

# Use Case

We're running an instance of [Linux Muster](https://www.linuxmuster.net/de/home/) on our school but are not satisfied with the built-in mechanism for distributing files across a course's set of students.
Our requirements:
- Access sharing files without logging in to the server (which causes indirection for less tech-savvy teacher colleagues)
- Asynchonous feedback about the process of sharing (e.g. progress bar)
- Copying files into the students' main folder instead of copying to `<student>/transfer/<teacher>/` (which causes indirection for younger students to find the files)
- Sharing with all students of a custom course (some courses are visited by students from different classes, like e.g. a computer science course has members from different classes in the grade)

# Current Solution

Bash scripts with zenity gui to:
- create custom courses (`gui-builder.sh`)
- share files with entire classes (or custom courses) (`gui-share.sh`)

# How it works

It creates a `.gui-share` folder in the users main folder (which, for us, is synced across devices using a nextcloud server). Inside there is a `Austeilen`-folder (source folder for sharing files) and a `Kurse`-folder for custom-created courses (see above). Each student in a custom course is a symlink to the folder in `Students-Home`, hence the teacher must be signed in to these students' main courses (aka classes). The share-script iterates the selected class (in `Students-Home`) or custom class (in `.gui-share/Kurse`) to copy.

# Problems Introduced

For reasons yet to be discovered, copying files into students folders keeps the original user (teacher account) as the files' owner, hence counting it towards the teachers quota instead of the students. Turns out this needs to be fixed on the server-side, because chown is not available to this degree as a standard domain user. The admins who are running the server agreed on cronjob'ing the `consolidate.sh` script, which fixes this.
