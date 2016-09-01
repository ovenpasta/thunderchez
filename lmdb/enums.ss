
(define-enumeration* mdb-cursor-op
  (first			;;< Position at first key/data item */
   first-dup		;;< Position at first data item of current key.
   ;;Only for #DUPSORT */
   get-both		;;< Position at key/data pair. Only for #DUPSORT */
   get-both-range	;;< position at key, nearest data. Only for #DUPSORT */
   get-current	;;< Return key/data at current cursor position */
   get-multiple	;;< Return key and up to a page of duplicate data items
   ;;from current cursor position. Move cursor to prepare
   ;;for #NEXT-MULTIPLE. Only for #DUPFIXED */
   last			;;< Position at last key/data item */
   last-dup		;;< Position at last data item of current key.
   ;;Only for #DUPSORT */
   next			;;< Position at next data item */
   next-dup		;;< Position at next data item of current key.
   ;;Only for #DUPSORT */
   next-multiple	;;< Return key and up to a page of duplicate data items
   ;;from next cursor position. Move cursor to prepare
   ;;for #NEXT-MULTIPLE. Only for #DUPFIXED */
   next-nodup		;;< Position at first data item of next key */
   prev			;;< Position at previous data item */
   prev-dup		;;< Position at previous data item of current key.
   ;;Only for #DUPSORT */
   prev-nodup		;;< Position at last data item of previous key */
   set			;;< Position at specified key */
   set-key		;;< Position at specified key, return key + data */
   set-range		;;< Position at first key greater than or equal to specified key. */
   prev-multiple))

