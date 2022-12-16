: abort ( -- ) -1 throw ;
: count ( adr -- adr n ) dup c@ swap 1+ swap + ;
: loadtest ( -- ) s" /spiffs/test.f" included ;
