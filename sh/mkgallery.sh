#!/bin/sh
#
############################################################################
# TITLE       : Instant Static Gallery
# PROJECT     : Websites
# ENGINEER    : waveclaw
# PROGRAM     : mkgallery.sh 
# FILE        : mkgallery.sh
# CREATED     : 12-JAN-2002 waveclaw
# DESCRIPTION : Make an instant image gallery with mogrify
# ASSUMPTIONS : Familiarity with bash 2.0, ImageMagick
############################################################################
#                          RELEASE LISCENSE		 
#
# 	This file is available under copyright  2002
#   For interal use only, keep out of young children. 
#   Lather, rinse, repeat. Do not taunt happy fun script.
# 									 
# 	Copyrights to their respective owners.				 
#									 
#  Current version : 0.2
#  Latest version  : 0.1
#  Bugs, Comments  : waveclaw@waveclaw.net
############################################################################

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/sbin

[ 0 -eq $UID ] && echo "Please do not run `basename $0` as root!" && exit;

if [ 1 -le $# ]; then 
	echo "Usage: `basename $0`";
echo <<'EOU';
bluk converter
(depends on sed for string replacement, gimp for graphics and shell
looping) Once you've saved the (massive) jpeg files, you can make
thumbnails and store them conveneiently with an index by your files.
EOU

exit;
fi

CREATE_DIR='/bin/mkdir';
WRITE='/bin/cat';
WRITE_LINE='/bin/echo';
MOVE='/bin/mv';
MAKE_THUMBNAIL='/usr/bin/mogrify -size 640x480';
table_row=0;

[ ! -d thumbnail ] && $CREATE_DIR thumbnail || exit;
[ ! -d image ] && $CREATE_DIR image || exit;

$WRITE <<EOHTMLHEADER > index.html
<HTML><HEAD>
<LINK rel=stylesheet href=styles-image.css type=text/css></LINK>
<TITLE>Automatic Graphics indexer output. Change Me.</TITLE></HEAD>
<BODY><TABLE>
EOHTMLHEADER

for graphics_file in *.jpg *.png *.gif *.bmp *.jpeg *.JPG;
do
	name=`echo $graphics_file | sed -e 's#\.???$##'`
	$MAKE_THUMBNAIL $graphics_file -resize 90x90 +profile "*";
	$MOVE ${name}.mgk thumbnail/${graphics_file};
	$MOVE ${graphics_file} image/${graphics_file};
	if [ "0" -eq "${table_row}" ]; 
	then
		$WRITE_LINE '<TR>' >> index.html;
		table_row=1;
	else
		$WRITE_LINE '<TR class=alt>' >> index.html;
		table_row=0;
	fi
$WRITE <<EOHTMLBODY >> index.html;
<td><!-- ThumbNail --><a href=image/${graphics_file}>
<img border=0 width=90 height=90 src=thumbnail/${graphics_file} alt=${graphics_file}></a></td>
<td width=90 valign=center><!-- Image Info -->
<div align=center><a href=image/${graphics_file}>${name}</a><br><u>11/15/2003</u>
<br>640x480<br>130.0 Kb<br></div></td>
<td valign=top><!-- Errata --><em>${name}</em> </td></TR>
EOHTMLBODY
done	

$WRITE <<EOHTMLFOOTER >> index.html
</TABLE>
</HTML>
EOHTMLFOOTER
