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

 (define-syntax mdb-define
   (syntax-rules ()
     ((_ name n) 
      (define-syntax name (identifier-syntax n)))))

(mdb-define MDB_SUCCESS	 0)
	;; key/data pair already exists 
(mdb-define MDB_KEYEXIST	-30799)
	;; key/data pair not found (EOF) 
(mdb-define MDB_NOTFOUND	-30798)
	;; Requested page not found - this usually indicates corruption 
(mdb-define MDB_PAGE_NOTFOUND	-30797)
	;; Located page was wrong type 
(mdb-define MDB_CORRUPTED	-30796)
	;; Update of meta page failed or environment had fatal error 
(mdb-define MDB_PANIC		-30795)
	;; Environment version mismatch 
(mdb-define MDB_VERSION_MISMATCH	-30794)
	;; File is not a valid LMDB file 
(mdb-define MDB_INVALID	-30793)
	;; Environment mapsize reached 
(mdb-define MDB_MAP_FULL	-30792)
	;; Environment maxdbs reached 
(mdb-define MDB_DBS_FULL	-30791)
	;; Environment maxreaders reached 
(mdb-define MDB_READERS_FULL	-30790)
	;; Too many TLS keys in use - Windows only 
(mdb-define MDB_TLS_FULL	-30789)
	;; Txn has too many dirty pages 
(mdb-define MDB_TXN_FULL	-30788)
	;; Cursor stack too deep - internal error 
(mdb-define MDB_CURSOR_FULL	-30787)
	;; Page has not enough space - internal error 
(mdb-define MDB_PAGE_FULL	-30786)
	;; Database contents grew beyond environment mapsize 
(mdb-define MDB_MAP_RESIZED	-30785)
	;; Operation and DB incompatible, or DB type changed. This can mean:
	;; *	<ul>
	;; *	<li>The operation expects an #MDB_DUPSORT / #MDB_DUPFIXED database.
	;; *	<li>Opening a named DB when the unnamed DB has #MDB_DUPSORT / #MDB_INTEGERKEY.
	;; *	<li>Accessing a data record as a database, or vice versa.
	;; *	<li>The database was dropped and recreated with different flags.
	;; *	</ul>
	 
(mdb-define MDB_INCOMPATIBLE	-30784)
	;; Invalid reuse of reader locktable slot 
(mdb-define MDB_BAD_RSLOT		-30783)
	;; Transaction must abort, has a child, or is invalid 
(mdb-define MDB_BAD_TXN			-30782)
	;; Unsupported size of key/DB name/data, or wrong DUPFIXED size 
(mdb-define MDB_BAD_VALSIZE		-30781)
	;; The specified DBI was changed unexpectedly 
(mdb-define MDB_BAD_DBI		-30780)
	;; Unexpected problem - txn should abort 
(mdb-define MDB_PROBLEM		-30779)
	;; The last defined error code 
(mdb-define MDB_LAST_ERRCODE	MDB_PROBLEM)




	;; mmap at a fixed address (experimental) */
(mdb-define  MDB_FIXEDMAP	#x01)
	;; no environment directory */
(mdb-define  MDB_NOSUBDIR	#x4000)
	;; don't fsync after commit */
(mdb-define  MDB_NOSYNC		#x10000)
	;; read only */
(mdb-define  MDB_RDONLY		#x20000)
	;; don't fsync metapage after commit */
(mdb-define  MDB_NOMETASYNC		#x40000)
	;; use writable mmap */
(mdb-define  MDB_WRITEMAP		#x80000)
	;; use asynchronous msync when #MDB_WRITEMAP is used */
(mdb-define  MDB_MAPASYNC		#x100000)
	;; tie reader locktable slots to #MDB_txn objects instead of to threads */
(mdb-define  MDB_NOTLS		#x200000)
	;; don't do any locking, caller must manage their own locks */
(mdb-define  MDB_NOLOCK		#x400000)
	;; don't do readahead (no effect on Windows) */
(mdb-define  MDB_NORDAHEAD	#x800000)
	;; don't initialize malloc'd memory before writing to datafile */
(mdb-define  MDB_NOMEMINIT	#x1000000)
;; @} */

;;	@defgroup	mdb_dbi_open	Database Flags
;; *	@{
;; */
	;; use reverse string keys */
(mdb-define  MDB_REVERSEKEY	#x02)
	;; use sorted duplicates */
(mdb-define  MDB_DUPSORT		#x04)
	;; numeric keys in native byte order, either unsigned int or #mdb_size_t.
	 ;;*	(lmdb expects 32-bit int <= size_t <= 32/64-bit mdb_size_t.)
	;; *  The keys must all be of the same size. */
(mdb-define  MDB_INTEGERKEY	#x08)
	;; with #MDB_DUPSORT, sorted dup items have fixed size */
(mdb-define  MDB_DUPFIXED	#x10)
	;; with #MDB_DUPSORT, dups are #MDB_INTEGERKEY-style integers */
(mdb-define  MDB_INTEGERDUP	#x20)
	;; with #MDB_DUPSORT, use reverse string dups */
(mdb-define  MDB_REVERSEDUP	#x40)
	;; create DB if not already existing */
(mdb-define  MDB_CREATE		#x40000)


;;	@defgroup mdb_put	Write Flags
;; *	@{
;; */
;; For put: Don't write if the key already exists. */
(mdb-define MDB_NOOVERWRITE	#x10)
;; Only for #MDB_DUPSORT<br>
;; * For put: don't write if the key and data pair already exist.<br>
;; * For mdb_cursor_del: remove all duplicate data items.
;; */
(mdb-define MDB_NODUPDATA	#x20)
;; For mdb_cursor_put: overwrite the current key/data pair */
(mdb-define MDB_CURRENT	#x40)
;; For put: Just reserve space for data, don't copy it. Return a
;; * pointer to the reserved space.
;; */
(mdb-define MDB_RESERVE	#x10000)
;; Data is being appended, don't split full pages. */
(mdb-define MDB_APPEND	#x20000)
;; Duplicate data is being appended, don't split full pages. */
(mdb-define MDB_APPENDDUP	#x40000)
;; Store multiple data items in one call. Only for #MDB_DUPFIXED. */
(mdb-define MDB_MULTIPLE	#x80000)
;;/*	@} */

(mdb-define MDB_VERSION_MAJOR 0)
(mdb-define MDB_VERSION_MINOR 9)
(mdb-define MDB_VERSION_PATCH 70)

;;	@defgroup mdb_copy	Copy Flags
;; *	@{
;; */
;; Compacting copy: Omit free space from copy, and renumber all
;; * pages sequentially.
;; */
(mdb-define MDB_CP_COMPACT	#x01)
;;/*	@} */

;; FIXME #ifdef _WIN32
 ;(mdb-define MDB_FMT_Z "I")
 ;#else
 (mdb-define MDB_FMT_Z "Z")
 ;#endif


