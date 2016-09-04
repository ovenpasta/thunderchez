;;
;; Copyright 2016 Aldo Nicolas Bruno
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

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

