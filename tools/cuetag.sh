#! /bin/sh

# cuetag - tag files based on cue/toc file information
# uses cueprint output

CUEPRINT=cueprint
cue_file=""

# Vorbis Comments
vorbis()
{
	VORBISCOMMENT=vorbiscomment

	# space seperated list of recomended stardard field names
	# see http://www.xiph.org/ogg/vorbis/doc/v-comment.html
	
	fields='TITLE VERSION ALBUM TRACKNUMBER ARTIST PERFORMER COPYRIGHT LICENSE ORGANIZATION DESCRIPTION GENRE DATE LOCATION CONTACT ISRC'

	# fields' corresponding cueprint conversion characters
	# seperate alternates with a space

	TITLE='%t'
	VERSION=''
	ALBUM='%T'
	TRACKNUMBER='%n'
	ARTIST='%c %p'
	PERFORMER='%p'
	COPYRIGHT=''
	LICENSE=''
	ORGANIZATION=''
	DESCRIPTION='%m'
	GENRE='%g'
	DATE=''
	LOCATION=''
	CONTACT=''
	ISRC='%i %u'

	for field in $fields; do
		value=""
		for conv in `eval echo \\$$field`; do
			value=`$CUEPRINT -n $1 -t "$conv\n" $cue_file`

			if [ -n "$value" ]; then
				break
			fi
		done

		if [ -n "$value" ]; then
			echo $VORBISCOMMENT -t "$field=$value" $2
		fi
	done
}

id3()
{
	MP3INFO=mp3info

	# space seperated list of ID3 v1.1 tags
	# see http://id3lib.sourceforge.net/id3/idev1.html

	fields="TITLE ALBUM ARTIST YEAR COMMENT GENRE TRACKNUMBER"

	# fields' corresponding cueprint conversion characters
	# seperate alternates with a space

	TITLE='%t'
	ALBUM='%T'
	ARTIST='%p'
	YEAR=''
	COMMENT='%c'
	GENRE='%g'
	TRACKNUMBER='%n'

	for field in $fields; do
		value=""
		for conv in `eval echo \\$$field`; do
			value=`$CUEPRINT -n $1 -t "$conv\n" $cue_file`

			if [ -n "$value" ]; then
				break
			fi
		done

		if [ -n "$value" ]; then
			case $field in
			TITLE)
				echo $MP3INFO -t "$value" $2
				;;
			ARTIST)
				echo $MP3INFO -a "$value" $2
				;;
			YEAR)
				echo $MP3INFO -y "$value" $2
				;;
			COMMENT)
				echo $MP3INFO -c "$value" $2
				;;
			GENRE)
				echo $MP3INFO -g "$value" $2
				;;
			TRACKNUMBER)
				echo $MP3INFO -n "$value" $2
				;;
			esac
		fi
	done
}

main()
{
	cue_file=$1
	shift

	ntrack=`cueprint -d '%N' $cue_file`
	trackno=1

	if [ $# -ne $ntrack ]; then
		echo "Number of files does not match number of tracks."
	fi

	for file in $@; do
		case $file in
		*.[Oo][Gg][Gg])
			vorbis $trackno "$file"
			;;
		*.[Mm][Pp]3)
			id3 $trackno "$file"
			;;
		*)
			echo "$file: uknown file type"
			;;
		esac
		trackno=$(($trackno + 1))
	done
}

main "$@"