include .make/Makefile

spelling:
	$(R_SCRIPT) -e "spelling::spell_check_package()"
	$(R_SCRIPT) -e "spelling::spell_check_files(c('NEWS.md'), ignore=readLines('inst/WORDLIST', warn=FALSE))"

future.tests/%:
	$(R_SCRIPT) -e "future.tests::check" --args --test-plan="future.mirai::$*"

future.tests/mirai_cluster:
	$(R_SCRIPT) -e "future.tests::check" --args --test-plan="mirai::daemons(2); plan(future.mirai::mirai_cluster)"

future.tests: future.tests/mirai_multisession future.tests/mirai_cluster

