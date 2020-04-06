ERL_INCLUDE_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)

all: native/kinext.so

native/kinext.so: native/nifs/kinext.c
	cc -fPIC -lfreenect -I$(ERL_INCLUDE_PATH) -dynamiclib -undefined dynamic_lookup -o ./native/kinext.so ./native/nifs/kinext.c