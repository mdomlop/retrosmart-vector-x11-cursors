#!/bin/sh

OUTDIR="$*"

TL="alias.in context-menu.in copy.in default.in dnd-move.in dnd-no-drop.in help.in no-drop.in pointer.in top_left_corner.in zoom-in.in zoom-out.in"
TC="center_ptr.in closedhand.in openhand.in top_side.in up-arrow.in"
TR="right_ptr.in top_right_corner.in"

CL="left_side.in left-arrow.in"
CC="all-scroll.in cell.in col-resize.in crosshair.in fleur.in not-allowed.in pirate.in row-resize.in size_bdiag.in size_fdiag.in size_hor.in size_ver.in text.in vertical-text.in wayland-cursor.in x-cursor.in"
CR="right-arrow.in right_side.in"

BL="bottom_left_corner.in color-picker.in draft.in pencil.in"
BC="bottom_side.in down-arrow.in"
BR="bottom_right_corner.in"


mk() {
# mk x y a s c
# x: n (null, zero), h (half), f (full), a (animation number), s(speed) configs
	x=$1
	shift
	y=$1
	shift
	a=$1
	shift
	s=$1
	shift
	configs=$@

	for config in $configs
	do
		> $OUTDIR/$config
		for size in $SIZES
		do
			if   [ "$x" = "n" ]; then px=0
			elif [ "$x" = "h" ]; then px=$(($size / 2))
			elif [ "$x" = "f" ]; then px=$size
			fi

			if   [ "$y" = "n" ]; then py=0
			elif [ "$y" = "h" ]; then py=$(($size / 2))
			elif [ "$y" = "f" ]; then py=$size
			fi

			base=$(basename $config .in)

			if [ $a = "n" ]; then
				echo $size $px $py $size-${base}.png
			else
				for step in $(seq -w 1 $a)
				do
					echo $size $px $py $size-${base}${step}.png $s
				done
			fi
		done >> $OUTDIR/$config
	done
}

mkdir -p $OUTDIR

mk n n n n "$TL"
mk h n n n "$TC"
mk f n n n "$TR"

mk n h n n "$CL"
mk h h n n "$CC"
mk f h n n "$CR"

mk n f n n "$BL"
mk h f n n "$BC"
mk f f n n "$BR"

mk n n 4 90 progress.in
mk h h 20 120 wait.in
