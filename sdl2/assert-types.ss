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

 (define-enumeration* sdl-assert-state
   (retry break abort ignore always-ignore))

 (define-ftype sdl-assert-data-t
   (struct 
    (always-ignore int)
    (trigger-count unsigned-int)
    (condition (* char))
    (filename (* char))
    (linenum int)
    (function (* char))
    (next (* sdl-assert-data-t))))
 (define-ftype sdl-assertion-handler-t void*)

